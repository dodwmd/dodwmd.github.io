.PHONY: help serve build deploy deploy-local clean

help:  ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

serve:  ## Run the dev server with drafts (http://localhost:1313)
	hugo server -D

build:  ## Build the site into public/
	HUGO_ENVIRONMENT=production hugo --gc --minify

deploy:  ## Build and push to the gh-pages branch (goes live)
	./deploy.sh

deploy-local:  ## Build and commit to gh-pages without pushing
	./deploy.sh --no-push

clean:  ## Remove build output
	rm -rf public resources .hugo_build.lock
