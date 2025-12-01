#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

new_pac=$(mktemp)

content=$(curl -sS --fail-early --fail-with-body 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf' | sed -nE 's!^server=/([-a-z0-9.]+)/[0-9.]+$!\1!p')
{
    echo -n "const domains = new Set('"
    head -c -1 <<<"$content" | tr '\n' ' '
    echo "'.split(' '));"
    tail -n +2 proxy.pac
} >$new_pac

if ! cmp -s proxy.pac $new_pac; then
    mv $new_pac proxy.pac
    changelog=$(cat debian/changelog)
    {
        echo "china-pac ($(date '+%y.%m.%d.%H')) unstable; urgency=medium"
        echo
        echo '  * New release.'
        echo
        echo " -- beavailable <beavailable@proton.me>  $(date '+%a, %d %b %Y %H:%M:%S %z')"
        echo
        echo "$changelog"
    } >debian/changelog
fi
