SHELL := /bin/bash

CDN_DISTRIBUTION_ID=E2FBUCKIRJBV3X
PUBLICATION_DOMAIN=mylifemap.io
VERSION=1.0.6# NOTE: Must change in ./mlm-website.js
AWS_VAULT_PROFILE=trent


# Package dependency managementdisallow-zircon-ruff

npm-install:  ## Install all packages
	@npm install

npm-clean:  ## Delete all packages
	@rm -rf node_modules/

npm-reinstall:
	@make npm-clean
	@make npm-install

npm-prune:  ## Prune all "extraneous" (unused) packages
	@npm prune

npm-prune-dry-run:
	@npm prune --dry-run


# Development

serve:  ## Serve the application locally for development work
	@npx web-dev-server

# See: https://github.com/webpack/webpack-cli/blob/master/SERVE-OPTIONS-v4.md
# https://webpack.js.org/api/cli/
serve-webpack:
	npx webpack serve \
		--open \
		--port 5500 \
		--watch-files * \
		--mode development \
		--entry ./mlm-website.js

# Production 

dist-clean:  ## Clean the distributable
	@rm -rf dist/

# Guide: https://lit.dev/docs/tools/production/
dist-build:  ## Build the distributable
	@npx rollup --config; \
	mkdir -p dist/assets; \
	cp assets/* dist/assets;

dist-serve:  ## Serve the distributable locally
	@open -a "Google Chrome" http://localhost:5500/dist/index.html; \
	npx web-dev-server \
		--port 5500 \
		--app-index dist/index.html \
		--watch;

dist-serve-old:
	@npx web-dev-server --port 5500 --app-index dist/index.html --open

dist-deploy-echo:
	@echo aws s3 sync ./dist s3://${PUBLICATION_DOMAIN}/${VERSION}/; \
	echo aws s3 sync ./dist s3://${PUBLICATION_DOMAIN}/;

dist-deploy:  ## Deploy distributable to CDN
	@aws s3 sync ./dist s3://${PUBLICATION_DOMAIN}/${VERSION}/; \
	aws s3 sync ./dist s3://${PUBLICATION_DOMAIN}/; \
	make dist-invalidate; \
	make dist-url;

dist-invalidate:  ## Invalidate all versions of app distributable on CDN
	@aws cloudfront create-invalidation --distribution-id ${CDN_DISTRIBUTION_ID} --paths "/*";

dist-url:  ## Print the distributed app URL
	@echo https://${PUBLICATION_DOMAIN}/${VERSION}/index.html; \
	echo https://${PUBLICATION_DOMAIN}/index.html;

dist-open:  ## Open the distributed app URL in a browser
	@open -a "Google Chrome" https://${PUBLICATION_DOMAIN}/index.html;


# Help

help:  ## Print Makefile usage. See: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
