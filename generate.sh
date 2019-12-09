#!/bin/bash

if [[ -z $1 ]]
then
    echo "You must specify the path to the data file in \$1."
    exit 1
else
    jsonpath=$1
    if [[ "${jsonpath:0:4}" == "http" ]]
    then
        curl -Lq $jsonpath -o "_temp.json"
        jsonpath="./_temp.json"
    fi
fi

if [[ -z $2 ]]
then
    lang="en"
else
    lang=$2
fi

if [[ ! -d dist  ]]
then
    mkdir dist
else
    rm -rf dist/*
fi

cp -r css dist

jq -f options.jq --slurpfile strings strings.json --arg lang $lang $jsonpath > options.json

pug -P -O options.json --out dist index.pug

rm -f _temp.json
