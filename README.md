---
title: "Slides und Pandoc"
subtitle: ""
author:
    - Sophie Eckenstaler 
    - Till Grallert
affiliation: Future e-Research Support in the Humanities, Humboldt-Universität zu Berlin
date: 2023-01-11
status: draft
license: https://creativecommons.org/licenses/by/4.0/
bibliography: 
    - ../../assets/bibliography/FuReSH.csl.json
    - /BachCloud/HUBox/assets/bibliography/FuReSH.csl.json
markdown: pandoc
lang: de
tags:
    - FuReSH
---

# 1. To do

- [ ] [Deutsche Label von Abbildungen](#abbildungen)
- [x] [Docker auf ARM Macs](#arm)
    + There is an issue in the [Pandoc repo on Github](https://github.com/pandoc/dockerfiles/issues/134).
    + work-arounds: 
        1. use the `ARM` branch, which relies on another Pandoc image. DOES NOT include the `pandoc-crossref` filter.
        2. use the `no-docker` branch, which requires a local Pandoc installation
- [x] Integration von [`pandoc-crossref`](https://github.com/lierdakil/pandoc-crossref) in Docker
- [ ] Integration von [`mermaid-filter`](https://github.com/raghur/mermaid-filter) für die Unterstützung von Diagrammen mit [mermaid.js](https://mermaid.js.org) in Docker
    + Ohne diese Integration bedarf es nur einer minimalen manuellen Bearbeitung des Outputs.
- [ ] Bashskript um zu prüfen ob Bilder in einem Ordner keine Copyright-Informationen haben und dieses dann auf einen voreingestellten Wert festlegen.

# 2. Allgemeines

Dieser Ordner enthält Vorlagen, Bashscripte und [CSL](https://citationstyles.org) Stile um mit der Hilfe von [Pandoc](https://pandoc.org) aus Markdown-Dateien verschiedene Outputformate zu generieren. Um die Abhängigkeit von spezifischen Nutzerrechnern zu minimieren, ist der Workflow über [Docker](http://docker.com) implementiert: die Bashscripte starten jeweils einen Docker Container mit Pandoc und führen dann die Transformation innerhalb des Containers aus. Pandoc bietet [offizielle Docker images](https://hub.docker.com/r/pandoc/) an. Das `pandoc/core` Image enthält die wichtigsten Erweiterungen, wie z.B. den `pandoc-crossref` Filter und einen Konverter für SVG Grafiken, die ansonsten manuell installiert werden müssten.

Die Ordnerstruktur ist wie folgt und darf **nicht geändert** werden, da die Bashscripte nach diesen Ordnern suchen:

- `_input/`: temporärer Ordner für Inputdateien. Diese müssen den Markdown-Konventionen entsprechen und mit der Dateiendung `.md` versehen sein
- `_output/`: temporärer Ordner für den durch die Bashscripte erzeugten Output
- `furesh-templates/`: Ordner für Formatvorlagen
    + `csl/`: Ordner für `CSL` Zitationsstile
    + `css/`: Ordner für `CSS` includes. Diese müssen `HTML` Snippets sein, also `CSS`, das von einem `<style type="text/css">` Tag umgeben ist.
- `pandoc-templates/`: Ordner mit Kopien der Standardvorlagen für Pandoc

## Wichtig: relative Links im YAML

Da die Inputdateien im Regelfall aus ihrem Ursprungskontext in the `_input/` Ordner verschoben werden, werden relative Links zu Bibliographien etc. im YAML Block der Inputdatei brechen. Diese müssen daher vor der Ausführung der Bashscripte kontrolliert und ggfs. korrigiert werden.

# 3. Installation und Ausführung

Nach dem Download dieses GitHub Repositoriums, müssen die Shell-Skripte ausführbar gemacht werden. Auf Unix-Systemen funktioniert dies mit dem Befehl `$ chmod u+x path/to/script.sh`. Mit `$ chmod -R u+x *.sh` können alle Shell-Skripte in einem Ordner ausführbar gemacht werden.

## mit Docker

Die präferierte und aktuell implementierte Option ist es, die Skripte in Docker laufen zu lassen, damit mögliche Abhängigkeiten von Docker gemanagt werden. Sämtliche Skripte in der `main` Branch benutzen Docker und können als Beispielcode herangezogen werden.

### ARM Macs {#arm}

Es gibt allerdings potentiell Probleme mit neuen ARM Macs, da nicht alle Docker Images für diese Architektur vorliegen. In dem Fall muss die `--platform` Flag gesetzt werden: `--platform linux/amd64` oder über `platform: linux/amd64` in einem Docker `compose.yaml`. Da das aktuelle `pandoc/core:latest` image trotzdem ohne Fehlermeldung keinerlei Output produziert, sind wir für ARM Geräte auf eine eigene Branch (`ARM`) umgestiegen. Diese funktioniert, allerdings noch ohne `pandoc-crossref`.

## ohne Docker

Dies erfordert, dass Pandoc auf dem lokalen System installiert ist und die Versionen von `pandoc-crossref` und `pandoc` miteinander kompatibel sind.

### Beispiel

```bash
#!/bin/bash
# change into the script directory
current_dir=$(dirname "${BASH_SOURCE[0]}")
cd $current_dir && pwd
# path to input directory
input_dir="$current_dir/_input"
#  path to output directory
output_dir="$current_dir/_output"
#  path to templates directory
templates_dir="$current_dir/furesh-templates"
csl="$templates_dir/csl/chicago-author-date_slides.csl"
# select template and output file name to be appended to the input file name
template="furesh-16to9-ccby.pptx"
output_name=$template
# cd into _input directory
cd $input_dir && pwd
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in *.md;  
    do name=${file%.*}
        pandoc -f markdown -t pptx -M "crossrefYaml=./pandoc-crossref-de.yml" --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;  
done
```

# Formattierung der Markdown-Dateien

Die Formattierung von Markdown-Datein für Slideshows wird im [Pandoc Manual](https://pandoc.org/MANUAL.html#slide-shows) beschrieben.

## Literaturangaben

Literaturangaben können mit Pandoc und Citeproc ganz simpel als `[@citekey]` gemacht werden. Die Bibliographie, am besten als `CSL JSON`, muss im YAML mit `bibliography: path/to/bibliography.csl.json` verlinkt werden. Beispielzitation [@Drucker2021DHCoursebook]

## Abbildungen {#abbildungen}

Abbildungen werden mit der Standardsyntax (`![alt text / caption](image-url.png)`) eingefügt. Zur Nummerierung von Abbildungen mit `pandoc-crossref` wird einfach `{#fig:your-label}` ans Ende gesetzt. Mit `pandoc-crossref-de.yml` wird die standardmäßige englische Ausgabe überschrieben (akutell deutsch). Referenziert werden Abbildungen mit `[@fig:your-label]`. Mit `\listoffigures` kann ein Abbildungsverzeichnis generiert werden.

**Bug:** Interpretiert Markdown Tag für Überschriften in `pandoc-crossref-de.yml` nicht.

### Copyright

Damit wir die Informationen zu Quellen und Rechten von Bildern im Ordner `assets/` nicht verlieren, können diese mit dem [ExifTool](https://exiftool.org/) in die Metadaten der Bilddateien geschrieben werden. Ein einfaches Kommando dazu ist

```bash
exiftool -exif:copyright="FuReSH, CC BY 4.0" -n path-to-image.jpg
```

### Graphiken mit Miroboards

Um das Seitenverhältnis des Viewports auf 16:9 Bildschirmen abzubilden, sollten "Frames" mit dem Seitenverhältnis 16:9 als Grundlage gewählt werden

## Notizen für die Präsentierenden

Einige Ausgabeformate unterstützen Notizen für die Präsentierenden: `reveal.js`, `PowerPoint (.pptx)`. Das Format sind `div`s der Klasse "notes":

```md
::: notes

Eine Notiz

:::
```

## Spalten

Zusätzlich zu den von Pandoc direkt unterstützten zweispaltigen Folien, enthält unser CSS Angaben für dreispaltige Layouts. Dieses wird über `<div>`s der Klasse `columns-3` umgesetzt:

```md
::: columns-3
:::: column

Erste Spalte

::::
:::: column

Zweite Spalte

::::
:::: column

Dritte Spalte

::::
:::
```

Außerdem können Spalten mit verschiedener Breite angelegt werden

```md
::: columns
:::: narrow

eine schmale Spalte

::::
:::: wide

eine breite Spalte

::::
:::

```


# Outputformate

Momentan unterstützt dieses Repositorium die Erzeugung von PowerPoint und HTML Folien.

## HTML Folien

Für HTML Folien benutzen wir das [revealJS Framework](https://revealjs.com), das nativ von Pandoc unterstützt wird. Es gibt auch noch ein Skript zur Erzeugung von `Slidy.js`Folien, diese werden aber nicht weiter gepflegt

## Grafiken als Hintergrundbild(er) mit RevealJS

Es gibt mehrer Möglichkeiten Hintergrundbilder einzubinden.

1. für die Gesamte Präsentation: über das YAML im Kopf der Datei `background-image: path-to-image`
2. für einzelne Slides: über das `@data-background-image="path-to-image"` Attribut

```md
# Folientitel {data-background-image="path-to-image" data-background-size="90%"}
```


## Powerpoint
### Fehler

Potentiel entstehen Fehler, wenn in den Formatvorlagen die einzelnen Folien nicht ihre englischen Standardnamen tragen. Diese dürfen nicht geändert werden, damit Pandoc die richtigen Folienvorlagen finden kann. Siehe dazu das Pandoc manual [hier](https://pandoc.org/MANUAL.html#templates) und [hier](https://pandoc.org/MANUAL.html#powerpoint-layout-choice)

### Regeln

- There must be at least 4 slides in the slide masters, named ppt/slideLayouts/slideLayout[1-4].xml
- ppt/slideLayouts/slideLayout1.xml is a title slide, and must:
    + have a `p:ph` element with type="ctrTitle"
    + have a `p:ph` element with type="subTitle"
    + have a `p:ph` element with type="dt"
- ppt/slideLayouts/slideLayout2.xml is a title + content slide, and must:
    - have a `p:ph` element with type="title"
    - have a `p:ph` element without a type attribute
- ppt/slideLayouts/slideLayout3.xml is a section header slide, and must:
    - have a `p:ph` element with either type="title" or type="ctrTitle"
- ppt/slideLayouts/slideLayout2.xml is a title + two-content slide, and must:
    - have a `p:ph` element with type="title"
    - have at least two `p:ph` elements without a type attribute

### Folienvorlagen

- Title Slide
    + >This layout is used for the initial slide, which is generated and filled from the metadata fields date, author, and title, if they are present.
- Section Header
    + >This layout is used for what pandoc calls “title slides”, i.e. slides which start with a header which is above the slide level in the hierarchy.
- Two Content
    + >This layout is used for two-column slides, i.e. slides containing a div with class columns which contains at least two divs with class column.
- Comparison
    - >This layout is used instead of “Two Content” for any two-column slides in which at least one column contains text followed by non-text (e.g. an image or a table).
- Content with Caption
    + >This layout is used for any non-two-column slides which contain text followed by non-text (e.g. an image or a table).
- Blank
    + >This layout is used for any slides which only contain blank content, e.g. a slide containing only speaker notes, or a slide containing only a non-breaking space.
- Title and Content
    + >This layout is used for all slides which do not match the criteria for another layout.

# Sample show

## Getting up

- Turn off alarm
- Get out of bed

## Breakfast

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

# In the evening

## Dinner

- Eat spaghetti
- Drink wine

------------------

![black box](../../../assets/images/blackbox/rId22.png)

## Going to sleep

- Get in bed
- Count sheep