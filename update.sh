#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
new_list=$(mktemp)

curl -sS --fail-early --fail-with-body "$url" | sed -nE 's!^server=/(([-a-z0-9]+\.)*[a-z]+)/[0-9.]+$!\1!p' >$new_list
if cmp -s $new_list domains.list; then
    rm $new_list
    exit
fi

mv $new_list domains.list

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
