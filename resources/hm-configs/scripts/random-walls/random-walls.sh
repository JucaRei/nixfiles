#!/usr/bin/env bash

set +e          # Disable errexit
set +u          # Disable nounset
set +o pipefail # Disable pipefail

watch -n 600 feh --randomize --big-fill "$HOME/Pictures/wallpapers/*"
