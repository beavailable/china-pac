#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
new_pac=$(mktemp)

content=$(curl -sS --fail-early --fail-with-body "$url" | sed -nE 's!^server=/(([-a-z0-9]+\.)*[a-z]+)/[0-9.]+$!\1!p' | paste -sd ' ')
{
    echo -n "const domains = new Set('"
    echo -n "$content"
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
