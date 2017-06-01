#!/usr/bin/env bash

DEPS=(greg)
if ! which greg 
then 
	echo "Please install greg"
	exit 2	
fi 

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

if [ ! -d "$HOME"/Podcasts/"$SITE_TITLE" ]
then
	mkdir -p "$HOME"/Podcasts/"$SITE_TITLE"	
fi 

greg sync "$SITE_TITLE" -dd "$HOME"/Podcasts/"$SITE_TITLE"

done

GREGLOCATION="$(which greg)"

CRONLOGLOCATION="$(pwd)"

if crontab -l | grep 'cronout.txt'
then
	echo "Success"
	exit 0
else

	echo "Set cron job to fetch RSS feed? (Y/n)"
	read CRONJOBREPLY

	if [ $CRONJOBREPLY == "Y" ]
	then 
		echo '*/5 * * * * '"$GREGLOCATION"' sync >> '"$CRONLOGLOCATION"'/cronout.txt' | crontab -
		echo "Cron job log for $0 set to report to $CRONLOGLOCATION/cronout.txt"
	exit 0
	fi
fi
