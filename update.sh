#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

# $@: arguments
_curl() {
    local retries
    retries=0
    while true; do
        if curl -sSL --fail-early --fail-with-body --connect-timeout 10 "$@"; then
            break
        fi
        ((++retries))
        if [[ $retries -ge 3 ]]; then
            return 1
        fi
        sleep $((retries * 5))
    done
}

url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
new_list=$(mktemp)

_curl "$url" | sed -nE 's!^server=/(([-a-z0-9]+\.)*[a-z]+)/[0-9.]+$!\1!p' | LC_ALL=C sort -u >$new_list
if [[ "${CHINA_PAC_FORCE_RELEASE:-}" != 'true' ]] && cmp -s $new_list default.list; then
    rm $new_list
    exit
fi

mv $new_list default.list

[[ -z "${CI:-}" ]] && exit

version=$(sed -nE '1s/^\S+ \((\S+)\) .+$/\1/p' debian/changelog)
new_version=$(date '+%y.%m')
if [[ "$version" == "$new_version"* ]]; then
    new_version="$new_version.$((${version##*.} + 1))"
else
    new_version="$new_version.0"
fi
changelog=$(cat debian/changelog)
{
    echo "china-pac ($new_version) unstable; urgency=medium"
    echo
    echo '  * New release.'
    echo
    echo " -- beavailable <beavailable@proton.me>  $(date '+%a, %d %b %Y %H:%M:%S %z')"
    echo
    echo "$changelog"
} >debian/changelog

user='github-actions[bot]'
email='41898282+github-actions[bot]@users.noreply.github.com'
git -c user.name="$user" -c user.email="$email" commit -am "Release $new_version" --author "$GITHUB_ACTOR <$GITHUB_ACTOR_ID+$GITHUB_ACTOR@users.noreply.github.com>"
git -c user.name="$user" -c user.email="$email" tag "$new_version" -am "Release $new_version"
git push origin --follow-tags --atomic

echo "release=true" >>$GITHUB_OUTPUT
