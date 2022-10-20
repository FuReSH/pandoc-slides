#!/bin/bash
# set platform for the Docker image
platform="linux/amd64" # for Apple silicon this must currently be set to "linux/amd64" and will run the pandoc image through the Rosetta2 emulator
pandoc_image="core:edge" # for Apple silicon this must be set to "core:edge"
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
# variables
output_format="slidy"
template="furesh.slidy"
output_name="furesh_slidy.html"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
# note that --template is called --reference-doc for pptx
for file in $input_dir/*.md;  
	do 
      [[ "$file" =~ \/[a-z0-9]+ ]]
		name="${BASH_REMATCH[0]}"
	   docker run --rm \
       --volume "$(pwd):/data" \
       --user $(id -u):$(id -g) \
       	--platform $platform \
       pandoc/$pandoc_image -f markdown -t $output_format \
       --citeproc --csl $csl \
       --include-in-header $css_dir/slides-furesh.html \
       --template $templates_dir/$template \
       $file -o $output_dir/$name-$output_name;
done