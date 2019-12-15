#!/bin/bash

# Stop script on error
set -e

function processDataPath {
    type=$1
    path=$2
    if [[ "${path:0:4}" == "http" ]]
    then
        filename="${type}_temp.json"
        curl -Lq $path -o $filename
        echo $filename
    else
        echo $path
    fi
}

while getopts "r:x:l:" option
do
 case "${option}"
 in
     r) releases=`processDataPath "releases" ${OPTARG}`;;
     x) records=`processDataPath "records" ${OPTARG}`;;
     l) lang=${OPTARG};;
 esac
done


if [[ -z $lang ]]
then
    lang="en"
fi

if [[ ! -s "$releases" ]]
then
    echo -e "[ERROR] You must at least specify the path or HTTP URL of an OCDS release package using -r [/path/to/release package].\nYou can optionnaly specify the path or HTTP URL of a record package using -x [/path/to/record package]."
    exit 1
elif [[ ! -s $records ]]
then
    records="./records_temp.json"

    echo -e "\nGenerating record package from release package..."
    cat $releases | ocdskit compile --package > $records
fi


if [[ ! -d dist  ]]
then
    mkdir dist
else
    rm -rf dist/*
fi

cp -r css dist

echo -e "Generating options.json..."
jq -f options.jq --slurpfile strings ./localization/strings.json --slurpfile records $records --arg lang $lang $releases > options.json

echo -e "Generating HTML..."
pug -P -O options.json --out dist index.pug

rm -f *_temp.json
