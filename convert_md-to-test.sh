#!/bin/bash
# path to input directory
input_dir="./_input"
#  path to output directory
output_dir="./_output"
#  path to csl
csl_dir="./furesh-templates/csl"
csl="$csl_dir/chicago-author-date_slides.csl"
# path to template directory
templates_dir="./furesh-templates"
# variables
output_format="slidy"
template="furesh.slidy"
output_name="furesh.html"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in $input_dir/*.md;  
	do name=${file%.*}
	    #pandoc -s -f markdown -t $output_format --filter=pandoc-crossref --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;  
		docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	pandoc/core:2.18 -s -f markdown -t $output_format --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;

done