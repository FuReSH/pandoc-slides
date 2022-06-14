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
# files
csl="$templates_dir/csl/chicago-author-date_slides.csl"
template="furesh-16to9-ccby.pptx"
output_name="furesh-16to9-ccby.pptx"
# cd into _input directory
cd $input_dir && pwd
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in *.md;  
	do name=${file%.*}
	    #pandoc -s -f markdown -t pptx --filter=pandoc-crossref --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;  
		docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	pandoc/core:2.18 -s -f markdown -t pptx --filter=pandoc-crossref --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;

done