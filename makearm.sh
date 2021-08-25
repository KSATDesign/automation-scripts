#!/usr/bin/env bash

echo "Hello, please answer the following to automate your Nethserver PI package build and to upload to the repo."
sleep 0.8s
echo -e
echo -n "What is the name of the package you are trying to build?"
echo -e
read -r name
echo -e
echo  "Where is the package source file located?"

read -r location
echo -e
sleep 0.5s
echo "Thank you processing your request this may take a moment"
sleep 0.5s
cd ~/development/nethserver && mkdir -p $name/org && cd $name/org && wget $location && cd .. && mock -r nethserver-7-armhfp resultdir=. org/*.src.rpm at the end run
cp *.armv7hl.rpm *noarch.rpm /home/repository/nethserver/7/local/armhfp/Packages/ && cp *.src.rpm /home/repository/nethserver/7/local/Source/
echo -e
sleep 0.5s
echo "Process completed successfully"
sleep 0.5s
echo "Have a nice day"