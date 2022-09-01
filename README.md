---
title: "Slides und Pandoc"
subtitle: ""
author:
    - Sophie Eckenstaler 
    - Till Grallert
affiliation: Future e-Research Support in the Humanities, Humboldt-Universität zu Berlin
date: 2022-07-12
status: draft
license: https://creativecommons.org/licenses/by/4.0/
bibliography: 
	../../assets/bibliography/FuReSH.csl.json
	/BachCloud/HUBox/assets/bibliography/FuReSH.csl.json
markdown: pandoc
lang: de
tags:
    - FuReSH
---

# To do

- [ ] siehe [Bug](#abbildungen)
- [x] Integration von [`pandoc-crossref`](https://github.com/lierdakil/pandoc-crossref) in Docker
- [ ] Integration von [`mermaid-filter`](https://github.com/raghur/mermaid-filter) in Docker

## Abbildungen {#abbildungen}

Zur Nummerierung von Abbildungen wird einfach `{#fig:your-label}` ans Ende gesetzt. Mit `pandoc-crossref-de.yml` wird die standardmäßige englische Ausgabe überschrieben (akutell deutsch). Referenziert werden Abbildungen mit `[@fig:your-label]`. Mit `\listoffigures` kann ein Abbildungsverzeichnis generiert werden.

**Bug:** Interpretiert Markdown Tag für Überschriften in `pandoc-crossref-de.yml` nicht.

# Allgemeines

Dieser Ordner enthält Vorlagen, Bashscripte und CSL Stile um mit der Hilfe von Pandoc aus Markdown-Dateien verschiedene Outputformate zu generieren. Um die Abhängigkeit von spezifischen Nutzerrechnern zu minimieren, ist der Workflow über Docker implementiert: die Bashscripte starten jeweils einen Docker Container mit Pandoc und führen dann die Transformation innerhalb des Containers aus. Pandoc bietet [offizielle Docker images](https://hub.docker.com/r/pandoc/core) an, die sogar die wichtigsten Erweiterungen, wie z.B. den `pandoc-crossref` Filter enthalten, der ansonsten manuell installiert werden muss.

Die Ordnerstruktur ist wie folgt und darf **nicht geändert** werden, da die Bashscripte nach diesen Ordnern suchen:

- `_input/`: temporärer Ordner für Inputdateien. Diese müssen den Markdown-Konventionen entsprechen und mit der Dateiendung `.md` versehen sein
- `_output/`: temporärer Ordner für den durch die Bashscripte erzeugten Output
- `furesh-templates/`: Ordner für Formatvorlagen
	+ `csl/`: Ordner für CSL Zitationsstile
- `pandoc-templates/`: Ordner mit Kopien der Standardvorlagen für Pandoc

## Wichtig: relative Links im YAML

Da die Inputdateien im Regelfall aus ihrem Ursprungskontext in the `_input/` Ordner verschoben werden, werden relative Links zu Bibliographien etc. im YAML Block der Inputdatei brechen. Diese müssen daher vor der Ausführung der Bashscripte kontrolliert und ggfs. korrigiert werden.

## Literaturangaben

Literaturangaben können mit Pandoc und Citeproc ganz simpel als `[@citekey]` gemacht werden. Die Bibliographie, am besten als `CSL JSON`, muss im YAML mit `bibliography: path/to/bibliography.csl.json` verlinkt werden. Beispielzitation [@Drucker2021DigitalHumanitiesCoursebook]

## Graphiken mit Miroboards

Um das Seitenverhältnis des Viewports auf 16:9 Bildschirmen abzubilden, sollten "Frames" mit dem Seitenverhältnis 16:9 als Grundlage gewählt werden

## Notizen für die Präsentierende

Einige Ausgabeformate unterstützen Notizen für die Präsentierenden: `reveal.js`, `PowerPoint (.pptx)`. Das Format sind `div`s der Klasse "notes":

```md
::: notes

Eine Notiz

:::
```

# mit Docker

Die präferierte Option ist, die Skripte in Docker laufen zu lassen, damit mögliche Abhängigkeiten von Docker gemanagt werden. 

## ARM Macs

Es gibt allerdings potentiell Probleme mit neuen ARM Macs, da nicht alle Docker Images für diese Architektur vorliegen. In dem Fall muss die `--platform` Flag gesetzt werden: `--platform linux/amd64` oder über `platform: linux/amd64` in einem Docker `compose.yaml`

## Beispiel

```bash
#!/bin/bash
# change into the script directory
current_dir=$(dirname "${BASH_SOURCE[0]}")
cd $current_dir && pwd
# path to input directory
input_dir="./_input"
#  path to output directory
output_dir="./_output"
#  path to csl
csl_dir="./furesh-templates/csl"
css_dir="./furesh-templates/css"
csl="$csl_dir/chicago-author-date_slides.csl"
# path to template directory
templates_dir="./furesh-templates"
# output variables
output_format="slidy"
template="furesh.slidy"
output_name="furesh.html"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
# note that --template is called --reference-doc for pptx
for file in $input_dir/*.md;  
	do 
      [[ "$file" =~ \/[a-z0-9]+ ]]
		name="${BASH_REMATCH[0]}"
	   docker run --rm \
       --volume "$(pwd):/data" \
       --user $(id -u):$(id -g) \
       pandoc/core:2.18 -f markdown -t $output_format -M "crossrefYaml=./pandoc-crossref-de.yml" --citeproc --csl $csl --include-in-header $css_dir/slidy-furesh.html --template $templates_dir/$template $file -o $output_dir/$name-$output_name;
done
```

## ohne Docker

Dies erfordert, dass Pandoc auf dem lokalen System installiert ist und die Versionen von `pandoc-crossref` und `pandoc` miteinander kompatibel sind.

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

## Make scripts executable

Jedes neue Script muss auf Unix-Systemen mit `$ chmod u+x path/to/script.sh` ausführbar gemacht werden. Nutze `$ chmod -R u+x *.sh` um alle shell scripte in einem Ordner ausführbarzu machen.

# Powerpoint
## Fehler

Potentiel entstehen Fehler, wenn in den Formatvorlagen die einzelnen Folien nicht ihre englischen Standardnamen tragen. Diese dürfen nicht geändert werden, damit Pandoc die richtigen Folienvorlagen finden kann. Siehe dazu das Pandoc manual [hier](https://pandoc.org/MANUAL.html#templates) und [hier](https://pandoc.org/MANUAL.html#powerpoint-layout-choice)

## Regeln

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

## Folienvorlagen

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