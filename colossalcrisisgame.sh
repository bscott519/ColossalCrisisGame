#!/bin/sh
echo -ne '\033c\033]0;Colossal Crisis\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/colossalcrisisgame.x86_64" "$@"
