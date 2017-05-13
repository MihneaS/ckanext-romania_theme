#!/bin/bash

# Acest fisier downloadeaza fisierul cu mime types aprovizionat de iana si
# il transforma pentru a a putea fi folosit de mimetype din python

url=https://www.iana.org/assignments/media-types/application.csv #mime types provided by iana
downloaded_file=$(basename "$url")
output_file=".mime.types"
spaces_per_tab=8;
characters_before_column2=40; # tabs counted as spaces_per_tab

repeatChar() {
    input=$1
    count=$2
    myString=$(printf "%${count}s")
    echo "${myString// /$input}"
}

cat > $output_file << 'endmsg'
###############################################################################
#
#  MIME media types and the extensions that represent them.
#
#  The format of this file is a media type on the left and zero or more
#  filename extensions on the right.  Programs using this file will map
#  files ending with those extensions to the associated type.
#
#  This file represents this project's mime types, in accordance to inna on
#  5 may 2017, with the exception on the xps extension. note that the
#  "mud+json application/mud+json" expires on 17 november 2017
#
###############################################################################

endmsg

wget "$url"
this_is_first_line=true;
while read -r line || [[ -n "$line" ]]; do
    if $this_is_first_line; then # jump over the name of the columns
        this_is_first_line=false;
        continue
    fi
    column2=$(cut -d, -f1 <<< $line | cut -d" " -f1 | tr "+" " ")
    column1=$(cut -d, -f2 <<< $line)

    if [ "$column2" == "vnd.ms-xpsdocument" ]; then
       column2=$column2" xps"
    fi
    spaces_between_columns=$(( characters_before_column2 - (${#column1} % characters_before_column2) ))

    tabs_count=$(( (spaces_between_columns + spaces_per_tab - 1) / spaces_per_tab))

    tabs=$(repeatChar "\t" $tabs_count);

    echo -e $column1$tabs$column2 >> $output_file
done < $downloaded_file
rm $downloaded_file
