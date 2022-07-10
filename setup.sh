#!/bin/bash

set -ex

git submodule update --init

cd ./scala_text
../sbt mdoc
cd ..
cp ./scala_text/book.json ./
cp -r ./scala_text/src/img ./
cp -r ./scala_text/src/example_projects ./
for f in ./img/*.svg
do
  if [[ $f =~ \./img/(.*)\.svg ]]; then
    SVG=`pwd`/img/${BASH_REMATCH[1]}.svg
    PDF=`pwd`/${BASH_REMATCH[1]}.pdf
    PDFTEX=`pwd`/${BASH_REMATCH[1]}.pdf_tex
    inkscape -D "$SVG" --export-filename="$PDF" --export-latex
    PAGES=$(egrep -a '/Type /Page\b' "$PDF" | wc -l | tr -d ' ')
    python3 ./python/fix_pdf_tex.py "$PAGES" < "$PDFTEX" > "$PDFTEX.tmp"
    mv "$PDFTEX.tmp" "$PDFTEX"
  fi
done

if [[ ! -d "./target" ]]; then
  mkdir target
fi

for f in ./scala_text/honkit/*.md
do
  if [[ $f =~ \./scala_text/honkit/(.*)\.md ]]; then
    cp $f ./target/
    FILENAME="${BASH_REMATCH[1]}.md" pandoc -o "./target/${BASH_REMATCH[1]}.tex" -f gfm+footnotes+header_attributes-hard_line_breaks-intraword_underscores --pdf-engine=lualatex --top-level-division=chapter --listings --filter ./python/filter.py $f
  fi
done

