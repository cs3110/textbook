# REMOTE is the name of the git remote that hosts
# https://github.com/cs3110/textbook. The gh-pages branch there is
# automatically served by https://cs3110.github.io/textbook.
REMOTE=public

BOOK=src
HTML=${BOOK}/_build/html
LATEX=${BOOK}/_build/latex
PDF_NAME=ocaml_programming.pdf

default: html

clean:
	jupyter-book clean ${BOOK}

html:
	jupyter-book build ${BOOK}

html-strict:
	jupyter-book build -W ${BOOK}

linkcheck:
	jupyter-book build ${BOOK} --builder linkcheck

view:
	open ${HTML}/index.html

pdf:
	jupyter-book build src --builder pdflatex

view-pdf:
	open ${LATEX}/book.pdf

deploy: html pdf
	cp ${LATEX}/book.pdf ${HTML}/${PDF_NAME} \
	  && ghp-import -n -p -f ${HTML} -r ${REMOTE} -m "Update textbook"

wc:
	find src/chapters -type f -name "*.md" -exec cat {} \; | pandoc -f commonmark -t plain | wc -w

wcl:
	find -E src/chapters -type f -name "*.md" -exec pandoc --lua-filter wordcount.lua {} \; | awk '{s+=$$1} END {print s}'

ccl:
	find -E src/chapters -type f -name "*.md" -exec pandoc --lua-filter codecount.lua {} \; | awk '{s+=$$1} END {print s}'
