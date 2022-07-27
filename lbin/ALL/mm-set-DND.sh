#!/bin/bash
#
# mm-set-DND.sh
# Benjamin Stier <b.stier@levigo.de>

# This is triggered by MeetingBar via this applescript
# use framework "Foundation"
# use scripting additions
# on meetingStart(eventId, title, allday, startDate, endDate, eventLocation, repeatingEvent, attendeeCount, meetingUrl, meetingService, meetingNotes)
#   set cocoaDate to current application's NSDate's dateWithTimeInterval:0 sinceDate:endDate
#   set theSeconds to cocoaDate's timeIntervalSince1970() as miles as string
#   do shell script "~/lbin/ALL/mm-set-DND.sh " & quoted form of theSeconds
# end meetingStart

# Load personal access token from file
# This should look like
# export MMTOKEN=mYPeRsONalAcCesStoKeN
# You can also set a chat URL
# export MM_URL=your-mattermost-url.com
. ~/.mm_access_token

: ${MM_URL:=your-mattermost-url.com}
END_DATE=${1:-0}

# Manipulate path. I know this is bad, but ¯\_(ツ)_/¯
for EXTRAPATH in /usr/local/bin; do
    if test -d "${EXTRAPATH}" && [[ ":$PATH:" != *":${EXTRAPATH}:"* ]]; then
        PATH="${PATH:+"$PATH:"}${EXTRAPATH}"
    fi
done

# Get user id from API
USER_ID=$(curl --location --request GET "https://${MM_URL}/api/v4/users/me" \
--header "Authorization: Bearer ${MMTOKEN}" \
--header 'Content-Type: application/json'  | jq --raw-output '.id' )

if test -z ${USER_ID}; then
    exit 2
fi


# Set user status to Do Not Disturb
curl --location --request PUT "https://${MM_URL}/api/v4/users/${USER_ID}/status" \
--header "Authorization: Bearer ${MMTOKEN}" \
--header 'Content-Type: application/json' \
--data-binary @- <<EOF
{
    "user_id": "${USER_ID}",
    "status": "dnd",
    "dnd_end_time": ${END_DATE}
}
EOF
