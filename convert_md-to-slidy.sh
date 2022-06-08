#!/bin/bash
# change into the script directory
current_dir=$(dirname "${BASH_SOURCE[0]}")
cd $current_dir && pwd
# path to input directory
input_dir="$current_dir/_input"
#  path to output directory
output_dir="$current_dir/_output"
#  path to csl
csl_dir="$current_dir/furesh-templates/csl"
csl="$csl_dir/chicago-author-date_slides.csl"
# path to template directory
templates_dir="$current_dir/furesh-templates"
# variables
output_format="html5"
template="furesh.slidy"
output_name="furesh.html"
# cd into _input directory
cd $input_dir && pwd
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
# note that --template is called --reference-doc for pptx
for file in *.md;  
	do name=${file%.*}
	    pandoc -s -f markdown -t $output_format --filter=pandoc-crossref --citeproc --csl $csl --template $templates_dir/$template $file -o $output_dir/$name-$output_name;  
done