.PHONY: help dev-install remove-dev-env
.DEFAULT_GOAL: help

help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
	printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

dev-install-serverextension:  ## Use poetry to install the server extension in dev mode 
	cd serverextension && \
		poetry install && \
		cd - && \
		jupyter serverextension enable --py jupyterlab_code_formatter

dev-install-labextension:  ## Use npm to install the lab extension in dev mode
	cd $(LABEXTENSION_PATH) && \
		npm install && \
		npm run build && \
		jupyter labextension link . && \
		cd -

dev-install: dev-install-serverextension dev-install-labextension  ## Install both lab and server extension in dev mode

dev-watch-labextension:  ## Recompile labextension on changes
	cd $(LABEXTENSION_PATH) && \
		npm run watch

dev-watch-jupyterlab:  ## Start jupyterlab under watch mode
	jupyter lab --watch

remove-dev-env:  # Remove all dev env dirs
	(rm -rf $(LABEXTENSION_PATH)/node_modules || echo "No node modules") && \
		(rm -rf $(SERVEREXTENSION_PATH)/.venv || echo "No venv")

lint:  # Run linters
	find serverextension -name '*.py' | xargs black --check && \
		cd $(LABEXTENSION_PATH) && \
		npm run lint

format:  # Run formatterse
	find serverextension -name '*.py' | xargs black && \
		cd $(LABEXTENSION_PATH) && \
		npm run format

test:  # Run test
	cd $(SERVEREXTENSION_PATH) && poetry run pytest
