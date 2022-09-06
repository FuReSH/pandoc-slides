#!/bin/bash
# change into the script directory
current_dir=$(dirname "${BASH_SOURCE[0]}")
cd $current_dir && pwd
# path to input directory
input_dir="./_input"
#  path to output directory
output_dir="./_output"
#  path to templates directory
templates_dir="./furesh-templates"
# files
csl="$templates_dir/csl/chicago-author-date_slides.csl"
template="furesh-4to3-ccby.pptx"
output_name="furesh-4to3-ccby.pptx"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in $input_dir/*.md; 
	do 
		[[ "$file" =~ \/[a-z0-9]+ ]]
		name="${BASH_REMATCH[0]}"
		docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	pandoc/core:2.18 -s -f markdown -t pptx --filter=pandoc-crossref -M "crossrefYaml=./pandoc-crossref-de.yml" --citeproc --csl $csl --reference-doc $templates_dir/$template $file -o $output_dir/$name-$output_name;

done