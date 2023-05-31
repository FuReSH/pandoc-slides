#!/bin/bash
pandoc_image="core:latest" # for Apple silicon this must be set to "core:edge"
# change into the script directory
current_dir=$(dirname "${BASH_SOURCE[0]}")
cd $current_dir && pwd
# path to input directory
input_dir="./_input"
#  path to output directory
output_dir="./_output"
#  path to csl
csl_dir="./furesh-templates/csl"
csl="$csl_dir/chicago-author-date_slides.csl"
#  path to css
css_dir="./furesh-templates/css"
# path to template directory
templates_dir="./furesh-templates"
# variables
output_format="markdown"
# template="furesh.slidy"
output_name="test.md"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in $input_dir/*.md;  
	do 
		[[ "$file" =~ \/[a-z0-9]+ ]]
		name="${BASH_REMATCH[0]}"
		podman run --rm \
       	--volume "$(pwd):/data" \
		--userns keep-id --user $(id -u):$(id -g) \
       	pandoc/$pandoc_image -s -f markdown -t $output_format \
       	$file -o $output_dir/$name-$output_name
done