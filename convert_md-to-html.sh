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
csl="$csl_dir/chicago-author-date.csl"
# variables
output_format="html5"
output_name="plain.html"
# convert all markdown files in the input directory using the defined template and csl styles and write the result to the output directory
for file in $input_dir/*.md;  
	do 
      [[ "$file" =~ \/[a-z0-9]+ ]]
		name="${BASH_REMATCH[0]}"
	   docker run --rm \
       --volume "$(pwd):/data" \
       --user $(id -u):$(id -g) \
       --platform $platform \
       pandoc/$pandoc_image -s -f markdown -t $output_format \
       --citeproc --csl $csl \
       $file -o $output_dir/$name-$output_name;
done