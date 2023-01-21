-include configs/example.env
-include configs/.active.env

SHELL := /bin/bash
EXAMPLE_CONFIG_FILE = /configs/.example.env

# Project
install: create_config docker_build docker_start

start: docker_start

set_env:
	. ./init.sh
#include_env:
#ifeq (,$(wildcard $(EXAMPLE_CONFIG_FILE)))
#	export $(shell egrep "^[^#;]" configs/example.env | xargs -d'\n' -n1)
#else
#	export $(shell egrep "^[^#;]" configs/.active.env | xargs -d'\n' -n1)
#endif
#	export $(shell egrep "^[^#;]" configs/.active.env | xargs -d'\n' -n1)
#	$(shell egrep "^[^#;]" configs/.$(BRANCH).env | xargs -d'\n' -n1 | sed 's/^/export /' > setenv.sh)
#	source ./setenv.sh

# Docker commands
docker_start:
	docker run -d --name $(CONTAINER) -p 80:80 --env-file configs/.active.env -v $(BRANCH):/test_app/docker/volumes --rm $(IMAGE)
docker_stop:
	docker stop $(CONTAINER)
docker_build:
	docker build -f docker/dockerfile -t $(IMAGE):$(TAG_OR_VERSION) .

# configs
switch_config:
	$(shell cp -n configs/.$(BRANCH).env configs/.active.env)
create_config:
ifeq (,$(wildcard $(EXAMPLE_CONFIG_FILE)))
	$(shell cp -n configs/example.env configs/.$(BRANCH).env)
	$(shell cp -n configs/example.env configs/.active.env)
	$(shell sed -i 's/var=.*/var=CHANGE_ME/' configs/example.env > configs/$(BRANCH).env)
	rm -f configs/example.env
else
	$(shell cp -n configs/.active.env configs/.$(BRANCH).env)
	$(shell sed -i 's/var=.*/var=CHANGE_ME/' configs/.active.env > configs/$(BRANCH).env)
endif
save_config:
	$(shell grep '^\BRANCH\>' configs/.active.env | $(shell cp -n configs/.active.env configs/.$(BRANCH).env))
	$(shell sed -i 's/var=.*/var=CHANGE_ME/' configs/.active.env > configs/$(BRANCH).env)

