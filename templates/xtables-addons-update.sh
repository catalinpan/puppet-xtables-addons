#!/bin/sh
GEOIP_MIRROR="http://geolite.maxmind.com/download/geoip/database"
TMPDIR=$(mktemp -d /tmp/geoipupdate.XXXXXXXXXX)

wget --no-verbose -t 3 -T 60 "${GEOIP_MIRROR}/GeoIPv6.csv.gz" -O "${TMPDIR}/GeoIPv6.csv.gz"
wget --no-verbose -t 3 -T 60 "${GEOIP_MIRROR}/GeoIPCountryCSV.zip" -O "${TMPDIR}/GeoIPCountryCSV.zip"
gzip -fdc ${TMPDIR}/GeoIPv6.csv.gz | ${TMPDIR}/GeoIPv6.csv
unzip -o -d ${TMPDIR} ${TMPDIR}/GeoIPCountryCSV.zip
mkdir -p /usr/share/xt_geoip
perl /opt/xtables-addons-1.41/geoip/xt_geoip_build -D /usr/share/xt_geoip ${TMPDIR}/GeoIP*.csv
[ -d "${TMPDIR}" ] |  rm -rf $TMPDIR
