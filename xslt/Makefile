# This makefile will generate the HTML for the entire project. It will read the
# set information from sets.xml and output index.html in the toplevel
# directory. It will also read the file photos.xml in each subdirectory. It
# will output a HTML file for each photo and an index.html file all of the
# photos in the subdirectory.

all:
	xsltproc all_sets.xsl ../sets.xml > ../index.html
	find .. -mindepth 1 -maxdepth 1 -type d | grep -v src | xargs -iphotoSet echo cd photoSet \; xsltproc ../src/set.xsl photos.xml \> index.html \; cd ../src | sh

