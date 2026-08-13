#!/bin/sh
# lf previewer: (1) filename (2) width (3) height (4) x (5) y (6) mode

file="$1"
width="$2"
height="$3"

case "$file" in
    *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tar.xz|*.tar.zst)
        tar tf "$file" || true
        ;;
    *.zip)
        unzip -l "$file" || true
        ;;
    *.pdf)
        pdftotext "$file" - || true
        ;;
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.bmp|*.tiff)
        chafa --size="${width}x${height}" "$file" || true
        ;;
    *)
        bat --color=always --style=plain --paging=never "$file" || cat "$file"
        ;;
esac
