#!/usr/bin/env bash

if [ -p /dev/stdin ]; then
    while IFS= read url; do
        yt-dlp -f 'ba' -x --audio-format mp3 "${url}"
    done

else
    if [ "$1" ]; then
        yt-dlp -f 'ba' -x --audio-format mp3 "${1}"
    else
        echo "you forgot to add a url"
    fi
fi
