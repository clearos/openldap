#!/bin/sh

# Run the upstream pre-start script
/usr/libexec/openldap/check-config.sh

# Load sysconfig parameters
[ ! -e /etc/sysconfig/slapd ] && exit 0
source /etc/sysconfig/slapd

[ -z "$SLAPD_URLS" ] && exit 0
[ -z "$BIND_POLICY" ] && exit 0

# Ugh - this permission issue catches end users all the time
chown -R ldap.ldap /var/lib/ldap

# Set SLAPD_URLS based on BIND_POLICY
if [ "$BIND_POLICY" == "localhost" ]; then
    # Do not bind to localhost:389 if Samba Directory is configured to run
    SAMBA_DIRECTORY_CONFIGURED=`grep "^driver[[:space:]]*=[[:space:]]*samba_directory" /var/clearos/accounts/config 2>/dev/null`
    if [ -n "$SAMBA_DIRECTORY_CONFIGURED" ]; then
        urls="ldaps://127.0.0.1/"
    else
        urls="ldap://127.0.0.1/"
    fi
elif [ "$BIND_POLICY" == "lan" ]; then
    urls="ldap://127.0.0.1/"

    if [ -x '/usr/sbin/network' ]; then
        lan_ips=`/usr/sbin/network --get-lan-ips | grep -v debug`
    else
        lan_ips=""
    fi

    for ip in $lan_ips; do
        urls="$urls ldaps://$ip/"
    done
elif [ "$BIND_POLICY" == "all" ]; then
    urls="ldap://127.0.0.1/ ldaps:///"
else
    exit 0
fi

if [ "$SLAPD_URLS" != "$urls" ]; then
    urls_sed=`echo $urls | sed 's/\//\\\\\//g'`
    sed -i -e "s/^SLAPD_URLS=.*/SLAPD_URLS=\"$urls_sed\"/" /etc/sysconfig/slapd
fi
