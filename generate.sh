#!/bin/bash

jq -f options.jq ~/git/decp-rama/json/decp.ocds.json > options.json

pug -O options.json index.pug
