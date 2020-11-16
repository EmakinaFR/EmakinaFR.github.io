install: ## Installs the dependencies needed to run the project.
	gem install bundler
	bundle install
.PHONY: install

serve: ## Serves the site locally with current and future posts.
	bundle exec jekyll serve --future --strict_front_matter --host=0.0.0.0 --livereload
.PHONY: serve

update: ## ## Updates the dependencies needed to run the project.
	bundle update
.PHONY: update

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' \
		| sed -e 's/\[32m##/[33m/'
.DEFAULT_GOAL := help
