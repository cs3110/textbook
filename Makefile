.PHONY: help notebooks stage deploy

BLUE=\033[0;34m
NOCOLOR=\033[0m

BOOK_URL=https://www.cs.cornell.edu/~clarkson/3110-2018fa/textbook

help:
	@echo "Please use 'make <target>' where <target> is one of:"
	@echo "  install       to install the plugins needed to build the book."
	@echo "  build         to build locally."
	@echo "  serve         to serve locally."
	@echo "  deploy        to deploy the book to the course website."
	@echo "  clean         to remove all generated files."

clean:
	rm -rf _book

install:
	gitbook install

build:
	gitbook build

serve:
	sleep 3 && open http://127.0.0.1:4000/ &
	gitbook serve

deploy:
	@echo "${BLUE}REMINDER: always 'make build' or 'make serve' before deploying.${NOCOLOR}"
	@echo ""
	@echo "${BLUE}Deploying book to course website.${NOCOLOR}"
	@echo "${BLUE}=================================${NOCOLOR}"
	./deploy.sh
	@echo ""
	@echo "${BLUE}    Done, see book at ${BOOK_URL}.${NOCOLOR}"
