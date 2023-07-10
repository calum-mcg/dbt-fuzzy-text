# dbt-fuzzy-text

Macros that help with fuzzy text matching, with the aim of keeping dbt models agnostic of data warehouses.

Current coverage:
| Algorithm | Snowflake | BigQuery |
| :--- | :----: | ---: |
| _Edit distance based_ |
| Levenshtein Distance | ✔️ | ✔️ |
| Jaro-Winkler Similarity | ✔️ | ❌ |

# Installation instructions

New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

1. Include this package in your `packages.yml` file — check [here](https://hub.getdbt.com/calum-mcg/latest/) for the latest version number:

```yml
packages:
  - package: calum-mcg/dbt-fuzzy-text
    version: X.X.X ## update to latest version here
```

2. Run `dbt deps` to install the package.

# Macros

## levenshtein_distance ([source](macros/levenshtein.sql))

This macro generates the levenshtein distance between two strings.

### Arguments

- `str1` (required): First string to compare
- `str2` (required): Second string to compare
- `max` (optional, default=none): Maximum distance to compute (integer)

### Usage:

Copy the macro into a statement tab in the dbt Cloud IDE, or into a model, and compile your code

```
 ... {{ fuzzy_text.levenshtein_distance('input_string_column', 'comparison_string_column') }} as levenshtein_distance ...
```

## jaro_winkler ([source](macros/jaro_winkler.sql))

This macro generates the Jaro-Winkler similarity between two strings.

### Arguments

- `str1` (required): First string to compare
- `str2` (required): Second string to compare

### Usage:

Copy the macro into a statement tab in the dbt Cloud IDE, or into a model, and compile your code

```
 ... {{ fuzzy_text.jaro_winkler('input_string_column', 'comparison_string_column') }} as jaro_winkler ...
```

## Contribution Guidelines

Pull requests are the best way to propose changes to the codebase. Steps required:

1. Create an issue in the repo with a description of the problem / bug / improvement required
2. Clone the `main` branch with a suitable branch name, e.g. `feature/add-cool-thing`
3. Add tests for supported adaptors in the `integration_tests` folder
4. If required, update the README documentation to include usage and an example.
5. Issue a pull request, provide:
   - a description of changes
   - add a reviewer
   - reference original issue (from step 1)
