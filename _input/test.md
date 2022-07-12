---
title: "Test for pandoc conversion"
subtitle: ""
author:
    - Sophie Eckenstaler 
    - Till Grallert
institute: Future e-Research Support in the Humanities, Humboldt-Universität zu Berlin
date: 2022-04-27 
status: draft
licence: https://creativecommons.org/licenses/by/4.0/
bibliography: https://furesh.github.io/slides/assets/bibliography/FuReSH.csl.json
markdown: pandoc
lang: de
tags:
    - FuReSH
---

# Sample show
## Getting up

- Turn off alarm
- Get out of bed

------------------

## Abbildungen

Zur Nummerierung von Abbildungen (siehe [@fig:black-box]) wird einfach `{#fig:your-label}` ans Ende gesetzt. Mit `pandoc-crossref-de.yml` wird die standardmäßige englische Ausgabe überschrieben (akutell deutsch).

![black box](https://furesh.github.io/slides/assets/images/blackbox/rId22.png){#fig:black-box}

## Multi-column layout

:::columns
::::column

### List

- Eat eggs
- Drink coffee

::::
::::column

### Lorem ipsum

Lorem ipsum dolor sit amet consectetur adipiscing elit euismod urna id ad vehicula ultrices, consequat dis ornare eu dapibus per pretium leo varius penatibus nulla magnis quisque, blandit interdum odio sodales senectus nascetur lacus eleifend sociosqu arcu molestie tempus. Fames maecenas hac venenatis iaculis metus consectetur tempor, sociosqu viverra posuere laoreet penatibus himenaeos congue habitant, varius justo sapien dis ultrices sociis. 

::::
:::

## Citations

Literaturangaben können mit Pandoc und Citeproc ganz simpel als `[@citekey]` gemacht werden. Die Bibliographie, am besten als `CSL JSON`, muss im YAML mit `bibliography: path/to/bibliography.csl.json` verlinkt werden. Beispielzitation [@Drucker2021DigitalHumanitiesCoursebook]

## Literatur {#refs}