#!/bin/bash

rm -rf "$2"/resized_images
mkdir "$2"/resized_images

IFS=","
for f in $1
do
  mogrify -format png -quality 9 -resize "1920x1080" -path "$2"/resized_images "$f"
done
