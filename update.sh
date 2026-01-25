#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

NEW_VERSION=''

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
fetch_new_version() {
    local url new_list version new_version
    url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
    new_list=$(mktemp)

    _curl "$url" | sed -nE 's!^server=/(([-a-z0-9]+\.)*[a-z]+)/[0-9.]+$!\1!p' | LC_ALL=C sort -u >$new_list
    if cmp -s $new_list default.list && [[ "${ENV_FORCE_RELEASE:-}" != 'true' ]]; then
        rm $new_list
        return
    fi

    mv $new_list default.list

    version=$(sed -nE '1s/^\S+ \((\S+)\) .+$/\1/p' debian/changelog)
    new_version=$(date '+%y.%m')
    if [[ "$version" == "$new_version"* ]]; then
        NEW_VERSION="$new_version.$((${version##*.} + 1))"
    else
        NEW_VERSION="$new_version.0"
    fi
}
release_new_version() {
    local changelog user email
    changelog=$(cat debian/changelog)
    {
        echo "china-pac ($NEW_VERSION) unstable; urgency=medium"
        echo
        echo '  * New release.'
        echo
        echo " -- beavailable <beavailable@proton.me>  $(date '+%a, %d %b %Y %H:%M:%S %z')"
        echo
        echo "$changelog"
    } >debian/changelog

    user='github-actions[bot]'
    email='41898282+github-actions[bot]@users.noreply.github.com'
    git -c user.name="$user" -c user.email="$email" commit -am "Release $NEW_VERSION" --author "$GITHUB_ACTOR <$GITHUB_ACTOR_ID+$GITHUB_ACTOR@users.noreply.github.com>"
    git -c user.name="$user" -c user.email="$email" tag "$NEW_VERSION" -am "Release $NEW_VERSION"
    git push origin --follow-tags --atomic
}

fetch_new_version
[[ -n "$NEW_VERSION" ]] || exit 0
[[ -n "${CI:-}" ]] || exit 0
release_new_version

echo "release=true" >>$GITHUB_OUTPUT
