#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

{
    echo -n "const domains = new Set('"
    echo -n "$(sed -nE '/^[^#]/p' domains.list extra.list | paste -sd ' ')"
    echo "'.split(' ');"
    tail +2 proxy.pac.template | sed -E "s/TEMPLATE_PROXY/$(cat proxy)/"
} >proxy.pac
