# OCDS static stats v0.1

A set of scripts to generate static HTML with OCDS statistics. No database required, just OCDS JSON.

## Requirements

- [jq](https://stedolan.github.io/jq/)
- [pug-cli](https://github.com/pugjs/pug-cli) (installed globally)
- curl

## Generating HTML

```
./generate.sh [path to data, can be HTTP remote] [optional language code]
```

Example with French data:

```
./generate.sh https://www.data.gouv.fr/fr/datasets/r/68bd2001-3420-4d94-bc49-c90878df322c en
```

## Localization

The file `strings.json` enables the localization of the labels.

## License

MIT
