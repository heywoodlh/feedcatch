#!/usr/bin/env bash

PODCASTS=$(greg list)

for p in $PODCASTS
do 
	greg remove "$p"
done
