#!/usr/bin/env bash
# Adapted from the Inngest updater in Nixpkgs. Requires nix, gh, jq, and coreutils.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

version=$(gh api repos/inngest/inngest/releases/latest --jq '.tag_name')
if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Expected a stable release tag, got: $version" >&2
  exit 1
fi
version=${version#v}

sources=$(nix eval --json .#packages --apply '
  packages: builtins.mapAttrs (_: p: {
    inherit (p.default) version;
    inherit (p.default.src) url outputHash;
  }) packages
')
current=$(jq -r '.["x86_64-linux"].version' <<< "$sources")
if [[ "$current" == "$version" ]]; then
  echo "Inngest is already up to date: $current"
  exit 0
fi
if [[ "$(printf '%s\n' "$current" "$version" | sort -V | head -n1)" != "$current" ]]; then
  echo "Refusing to downgrade Inngest from $current to $version" >&2
  exit 1
fi

# Do not change package.nix unless every archive is available and verified.
tmp=$(mktemp -d .update.XXXXXX)
trap 'rm -rf "$tmp"' EXIT
gh release download "v$version" --repo inngest/inngest \
  --pattern checksums.txt --output "$tmp/checksums.txt"
package=$(cat package.nix)

while IFS=$'\t' read -r system url old_hash; do
  url=${url//"$current"/"$version"}
  archive=${url##*/}
  read -r checksum filename < <(grep -F "  $archive" "$tmp/checksums.txt")
  if [[ "$filename" != "$archive" || ! "$checksum" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Missing or invalid checksum for $archive" >&2
    exit 1
  fi
  hash=$(nix hash convert --hash-algo sha256 --to sri "$checksum")
  nix store prefetch-file --expected-hash "$hash" "$url"
  package=${package//"$old_hash"/"$hash"}
  echo "Verified $system: $archive"
done < <(jq -r 'to_entries[] | [.key, .value.url, .value.outputHash] | @tsv' <<< "$sources")

package=${package/"version = \"$current\";"/"version = \"$version\";"}
printf '%s\n' "$package" > "$tmp/package.nix"
chmod 644 "$tmp/package.nix"
mv "$tmp/package.nix" package.nix
echo "Updated Inngest $current -> $version"
