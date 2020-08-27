#!/bin/sh

export DEPARTURE_KEY=SECRET
export HASS_AUTH_KEY=SECRET
export ICAL_URL=SECRET
export QT_QPA_EGLFS_KMS_CONFIG=/home/pi/hass-clock/hassframe-ui/kms.conf

echo "18" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio18/direction

./hassframe-ui -platform eglfs
