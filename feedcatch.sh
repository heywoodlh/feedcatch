#!/usr/bin/env bash

RSSFEEDURL="$1"

python_catcher() { 
python -c "import feedparser 
rssfeedurl = \"$RSSFEEDURL\"
d = feedparser.parse(rssfeedurl) 
title = d['feed']['title']
titlenospace = title.replace(' ', '')
print(titlenospace)"
}


SITE_TITLE=$(python_catcher)

echo "Found RSS feed for $SITE_TITLE"

greg add "$SITE_TITLE" "$1"

greg check -f "$SITE_TITLE" >> /dev/null

echo "Set cron job to fetch RSS feed? (Y/n)"
read CRONJOBREPLY

if [ $CRONJOBREPLY == "Y" ]
then 
	echo "@daily greg sync" | crontab -
exit 0
fi
