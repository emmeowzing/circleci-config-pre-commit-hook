#! /usr/bin/env bash

set -e

if [[ -n $CIRCLECI ]]; then
    echo "Circleci environment detected, skipping validation."
    exit 0
fi

if ! command -v circleci &>/dev/null; then
    echo "Circleci CLI could not be found. Install the latest CLI version https://circleci.com/docs/2.0/local-cli/#installation"
    exit 1
fi

for cmd in yq jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "$cmd CLI could not be found, please install."
        exit 1
    fi
done

if [ ! -d .circleci/ ]; then
    exit 0
fi

# Process all config files for independent validity.
mapfile -t mods < <(find .circleci -type f \( -iname "*.yml" \))

for config in "${mods[@]}"; do
    orbs="$(yq -c '.orbs | flatten')"
    length="$(echo "$orbs" | jq 'length')"
    for (( i=0; i<$length; ++i )); do
        orb="$(echo "$orbs" | jq ".[$i]")"
        organization="$(echo "$orb" | grep -oP ".*(?=@)")"
        version="$(echo "$orb" | grep -oP "(?<=@).*")"
        
        # Ensure the orb exists in the registry.
        if ! circleci orb info "$organization" 2>/dev/null; then
            echo "** Error: orb \"$organization\" does not exist. Consider using the CircleCI config validation hook first."
        fi

        # Check the versions.
        latest_version="$(circleci orb info "$organization" | grep -oP "(?<=@).*")"
        if [ "$latest_version" != "$version" ]; then
            printf "** Warning: orb %s in config %s is not the latest version. Consider upgrading to version %s.\\n" "$version" "$config" "$latest_version" 1>&2
        fi
    done
done
