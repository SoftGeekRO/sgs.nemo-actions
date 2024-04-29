#!/bin/bash

IFS=","
for f in $1
do
  mogrify -format png -quality 9 "$f"
done
