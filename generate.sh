#!/usr/bin/bash
set -euo pipefail
shopt -s inherit_errexit

if [[ "${1:-}" == 'configure' ]]; then
    CONFIG_DIR='/etc/china-pac'
    TEMPLATE_DIR='/usr/share/china-pac'
    PAC_DIR='/var/lib/china-pac'
else
    CONFIG_DIR='.'
    TEMPLATE_DIR='.'
    PAC_DIR='.'
fi

echo "Generating file $PAC_DIR/proxy.pac"

{
    echo -n "const domains = new Set('"
    echo -n "$(sed -nE -e '/^#/d' -e '/^\S+$/p' $CONFIG_DIR/{default,extra}.list | paste -sd ' ')"
    echo "'.split(' '));"
    tail +2 $TEMPLATE_DIR/proxy.pac.template | sed -E "s/TEMPLATE_PROXY/$(cat $CONFIG_DIR/proxy)/"
} >$PAC_DIR/proxy.pac

echo 'Done'
