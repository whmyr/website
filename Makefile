# Makefile for Sphinx documentation

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = build

# Internal variables.
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(SPHINXOPTS) source
SPHINX_LIVE_PORT = 8001

DEPLOY_HOST   = daniel-siepmann.de
DEPLOY_PATH   = htdocs/daniel-siepmann.de
DEPLOY_PATH   = htdocs/new.daniel-siepmann.de

COMPASS_CONFIG_PATH = source/_compass/

.PHONY: help
help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo " Generation: "
	@echo "     html        to make standalone HTML files"
	@echo "     dirhtml     to make HTML files named index.html in directories"
	@echo "     singlehtml  to make a single large HTML file"
	@echo " Validation and deployment: "
	@echo "     changes     to make an overview of all changed/added/deprecated items"
	@echo "     linkcheck   to check all external links for integrity"
	@echo "     deploy      to deploy the generated HTML to production"
	@echo " Environment setup: "
	@echo "     clean       to remove build results"
	@echo "     install     to install all dependencies local for current user"
	@echo "     optimize    to optimize images"

.PHONY: install
install:
	pip install --user --upgrade -r requirements.txt
	gem install bundler --no-document --user-install
	bundle install
	brew install pngquant optipng

.PHONY: optimize
optimize:
	pngquant -v source/images/**/*.png --ext .png -f
	optipng source/images/**/*.png

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)/*

.PHONY: livehtml
livehtml: clean css
	# Ignore some folders and define port
	sphinx-autobuild -b html -i '*.sw[pmnox]' -i '*.dotfiles/*' -i '*/_compass/*' -i '.git*' -i '*~' -p $(SPHINX_LIVE_PORT) $(ALLSPHINXOPTS) $(BUILDDIR)/html

.PHONY: html
html: clean css
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

.PHONY: dirhtml
dirhtml: css optimize
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) $(BUILDDIR)/dirhtml
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/dirhtml."

.PHONY: singlehtml
singlehtml: css optimize
	$(SPHINXBUILD) -b singlehtml $(ALLSPHINXOPTS) $(BUILDDIR)/singlehtml
	@echo
	@echo "Build finished. The HTML page is in $(BUILDDIR)/singlehtml."

.PHONY: changes
changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) $(BUILDDIR)/changes
	@echo
	@echo "The overview file is in $(BUILDDIR)/changes."

.PHONY: linkcheck
linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) $(BUILDDIR)/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in $(BUILDDIR)/linkcheck/output.txt."

.PHONY: css
css:
	cd $(COMPASS_CONFIG_PATH) && compass compile --force

.PHONY: deploy
deploy: clean css html optimize
	rsync --delete -vaz $(BUILDDIR)/html/* $(DEPLOY_HOST):$(DEPLOY_PATH)

.PHONY: deploy-light
deploy-light: clean css html
	rsync --delete -vaz $(BUILDDIR)/html/* $(DEPLOY_HOST):$(DEPLOY_PATH)
