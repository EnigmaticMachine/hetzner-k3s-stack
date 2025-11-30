IMAGE_NAME := steezr-infra-cli
INSIDE_DOCKER := $(shell [ -f /.dockerenv ] && echo true)

.PHONY: all deploy destroy shell

ifndef INSIDE_DOCKER
# --- HOST MACHINE LOGIC ---
%:
	@echo "🐳 Starting Toolchain Container..."
	@docker build -q -t $(IMAGE_NAME) -f build/Dockerfile . > /dev/null
	@docker run --rm -it \
		-v "$(PWD):/project" \
		-v "$(HOME)/.ssh:/root/.ssh" \
		-e HCLOUD_TOKEN \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		$(IMAGE_NAME) make $@

shell:
	@docker build -q -t $(IMAGE_NAME) -f build/Dockerfile . > /dev/null
	@docker run --rm -it \
		-v "$(PWD):/project" \
		-v "$(HOME)/.ssh:/root/.ssh" \
		-e HCLOUD_TOKEN \
		$(IMAGE_NAME) /bin/bash

else
# --- INSIDE CONTAINER LOGIC ---
deploy:
	@bash scripts/deploy.sh

destroy:
	@bash scripts/destroy.sh

endif
