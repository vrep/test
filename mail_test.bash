#!/usr/local/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:.

declare -a email_array=(skindig@crutchfield.com sschwartz@crutchfield.com \
    talvis@crutchfield.com tczys2@crutchfield.com  \
    tfreeman@crutchfield.com tstinnett@crutchfield.com \
    tkinstle@crutchfield.com markbol@crutchfield.com  \
    tbingler@crutchfield.com cvanhuss@crutchfield.com \
    charlesc@crutchfield.com vpalabrica@crutchfield.com \
    wbearden@crutchfield.com amym@crutchfield.com
)

for element in ${email_array[*]}
do
    echo "Sending test email to $element"
    echo "Test email from Virtual-Representative, please ignore." |mailx -s TestEmail $element
done 
