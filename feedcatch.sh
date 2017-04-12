#!/usr/bin/env bash

for URL in "$@"; do


python_catcher() { 
python3 -c "import feedparser 
rssfeedurl = \"$URL\"
d = feedparser.parse(rssfeedurl) 
title = d['feed']['title']
titlenospace = title.replace(' ', '')
print(titlenospace)"
}


SITE_TITLE=$(python_catcher)

GREGCONF=$(greg retrieveglobalconf)


if [ ! -w $GREGCONF ] && grep "Create subdirectory = no" "$GREGCONF"
then 	
	sudo sed -i '/Create subdirectory = no/c\Create subdirectory = yes' "$GREGCONF"

elif grep "Create subdirectory = no" "$GREGCONF"
then
	sed -i '/Create subdirectory = no/c\Create subdirectory = yes' "$GREGCONF"
fi

echo "Found RSS feed for $SITE_TITLE"


greg add "$SITE_TITLE" "$URL"

greg check -f "$SITE_TITLE" >> /dev/null

if [ ! -d ~/Podcasts/"$SITE_TITLE" ]
then
	mkdir -p ~/Podcasts/"$SITE_TITLE"	
fi 

greg sync -dd ~/Podcasts/"$SITE_TITLE"

done

GREGLOCATION="$(which greg)"

if crontab -l | grep '*/5 * * * * '"$GREGLOCATION"' sync >> cronout.txt'
then
	exit 0
else

	echo "Set cron job to fetch RSS feed? (Y/n)"
	read CRONJOBREPLY

	if [ $CRONJOBREPLY == "Y" ]
	then 
		echo '*/5 * * * * '"$GREGLOCATION"' sync >> cronout.txt' | crontab -
	exit 0
	fi
fi
