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

if ! command -v yq &>/dev/null; then
    echo "yq could not be found. Install the latest CLI version with 'brew install yq'"
    exit 1
fi

echo "$@"

# Validate the standard CircleCI config.
if ! eMSG=$(circleci config validate "$@" -c .circleci/config.yml); then
    echo "CircleCI Configuration Failed Validation."
    echo "${eMSG}"
    exit 1
fi

# Now process the dynamic-continuation generated / reduced configuration file.
mapfile -t mods < <(find .circleci -type f \( -iname "*.yml" ! -iname "config.yml" \))

if [ "${#mods[@]}" -ne 0 ]; then
    continueConfig="$(mktemp)"
    yq ea ". as \$item ireduce ({}; . * \$item)" "${mods[@]}" | tee "$continueConfig"
    yq -i '.version = 2.1' "$continueConfig"
    yq 'del(.setup)' "$continueConfig"
    yq -i '.workflows.version = 2' "$continueConfig"

    if ! reMSG=$(circleci config validate "$@" -c "$continueConfig"); then
        echo "CircleCI dynamic-continuation configuration failed validation."
        echo "${reMSG}"
        exit 1
    fi
fi
