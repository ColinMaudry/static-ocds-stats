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

function printUsage {
    echo "Generates HTML pages to show statistics about OCDS data.

    Options:

    -r: path or HTTP URL to a release package (mandatory)
    -x: path or HTTP URL to a record package (optional)
    -l: output language (en or fr) (optional, defaults to en)
    -s: sets the beginning of the time range to filter releases (format YYYY-MM-DD, optional)
    -e: sets the end of the time range to filter releases (format YYYY-MM-DD, optional)
    "
}

while getopts "r:x:l:s:e:" option
do
 case "${option}"
 in
     r) releases=`processDataPath "releases" ${OPTARG}`;;
     x) records=`processDataPath "records" ${OPTARG}`;;
     l) lang=${OPTARG};;
     s) startDate=${OPTARG};;
     e) endDate=${OPTARG};;
 esac
done

if [[ -z $lang ]]
then
    lang="en"
fi

if [[ -z $startDate ]]
then
    startDateIso="1970-01-01T00:00:00Z"
else
    startDateIso="${startDate}T00:00:00Z"
fi

if [[ -z $endDate ]]
then
    endDateIso="3000-12-31T00:00:00Z"
else
    endDateIso="${endDate}T00:00:00Z"
fi

if [[ ! -s "$releases" ]]
then
    echo -e "[ERROR] You must at least specify the path or HTTP URL of an OCDS release package using -r [/path/to/release package].\nYou can optionnaly specify the path or HTTP URL of a record package using -x [/path/to/record package]."
    exit 1
elif [[ ! -s $records ]]
then
    if [[ $startDate || $endDate ]]
    then
        echo "Filtering releases by date..."
        jq -f startEndDate.jq --arg startDateIso $startDateIso --arg endDateIso $endDateIso $releases > temp_releases.json
        releases=temp_releases.json
        if [[ `jq '.releases | length' $releases` -eq 0 ]]
        then
            echo "[ERROR] The release array is empty. Is the time range too tight? ($startDateIso - $endDateIso)."
            exit 0
        fi
    fi

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
