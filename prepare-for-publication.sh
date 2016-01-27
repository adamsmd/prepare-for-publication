#! /bin/bash
set -e

usage () {
  echo "Usage: prepare-for-publication INPUT_PDF OUTPUT_PDF [ACM.joboptions]"
  exit 1
}

if test 2 -ne $# -a 3 -ne $#; then echo "Error: incorrect number of arguments"; usage; fi

INPUT="$1"
OUTPUT="$2"
if test 3 -eq $#; then
  JOBOPTIONS="$3"
else
  JOBOPTIONS=ACM.joboptions
fi

if test ! -f "$INPUT"; then echo "Error: cannot find input file"; usage; fi
if test ! -r "$INPUT"; then echo "Error: cannot read input file"; usage; fi
if test -f "$OUTPUT" -a ! -w "$INPUT"; then echo "Error: cannot write to output file"; usage; fi
if test ! -f "$JOBOPTIONS"; then echo "Error: cannot find ACM.joboptions"; usage; fi
if test ! -r "$JOBOPTIONS"; then echo "Error: cannot read ACM.joboptions"; usage; fi

TITLE=$(pdfinfo "$INPUT" | perl -ne 'print $1 if /^Title: +(.*)$/')
KEYWORDS=$(pdfinfo "$INPUT" | perl -ne 'print $1 if /^Keywords: +(.*)$/')
AUTHOR=$(pdfinfo "$INPUT" | perl -ne 'print $1 if /^Author: +(.*)$/')

#-dFastWebView=true # We omit this as it breaks in strange ways

rm -f "$OUTPUT" && \
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="$OUTPUT" -f "$JOBOPTIONS" "$INPUT"  && \
(echo; set -x; pdfinfo "$OUTPUT") || (\
echo && \
echo '!!!!!!!!!!!!!!!!!!' && \
echo '!! BUILD FAILED !!' && \
echo '!!!!!!!!!!!!!!!!!!' && exit 1)

echo
echo '+++++++++++++++++' && \
echo '+ BUILD SUCCESS +' && \
echo '+++++++++++++++++' 
echo '+ Check that the following extracted from the input match the above results from "pdfinfo"'
echo '+'
echo '+ Title:' "$TITLE"
echo '+ Keywords:' "$KEYWORDS"
echo '+ Author:' "$AUTHOR"
echo '+++++++++++++++++'

# If things don't match up add the following to the options of 'gs':
#   -c "[
#   /Author ($AUTHOR)
#   /Title ($TITLE)
#   /Keywords ($KEYWORDS)
#   /DOCINFO pdfmark"
# But be careful.  These may break if there is unicode.
