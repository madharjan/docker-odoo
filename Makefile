
NAME = madharjan/docker-odoo
VERSION = 12.0

DEBUG ?= true

DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	docker build \
		--build-arg ODOO_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=${DEBUG} \
		-t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	
	rm -rf /tmp/odoo
	mkdir -p /tmp/odoo/etc/
	mkdir -p /tmp/odoo/addons/
	mkdir -p /tmp/odoo/lib/

	docker run -d \
		-e POSTGRESQL_USERNAME=odoo \
		-e POSTGRESQL_PASSWORD=odoo \
		--name odoo-postgresql madharjan/docker-postgresql:9.5

	sleep 2

	docker run -d \
		-e POSTGRESQL_USERNAME=odoo \
		-e POSTGRESQL_PASSWORD=odoo \
		--name odoo-postgresql_default madharjan/docker-postgresql:9.5

	sleep 2

	docker run -d \
		--link odoo-postgresql:postgresql \
		-e ODOO_ADMIN_PASSWORD=Pa55w0rd \
		-e ODOO_ADMIN_EMAIL=admin@local.host \
		-e DEBUG=${DEBUG} \
		-v /tmp/odoo/etc:/etc/odoo \
		-v /tmp/odoo/addons:/opt/odoo/extra \
		-v /tmp/odoo/lib:/var/lib/odoo \
		--name odoo $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		--link odoo-postgresql:postgresql \
		-e DISABLE_ODOO=1 \
		-e DEBUG=${DEBUG} \
		--name odoo_no_odoo $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		--link odoo-postgresql_default:postgresql \
		-e DEBUG=${DEBUG} \
		--name odoo_default $(NAME):$(VERSION)

	sleep 5

test:
	#sleep 190
	./bats/bin/bats test/tests.bats

stop:
	docker exec odoo /bin/bash -c "sv stop odoo" 2> /dev/null || true
	sleep 6
	docker exec odoo /bin/bash -c "rm -rf /etc/odoo/*" 2> /dev/null || true
	docker exec odoo /bin/bash -c "rm -rf /var/lib/odoo/*" 2> /dev/null || true
	docker stop odoo odoo_no_odoo odoo_default odoo-postgresql odoo-postgresql_default 2> /dev/null || true

clean: stop
	docker rm odoo odoo_no_odoo odoo_default odoo-postgresql odoo-postgresql_default 2> /dev/null || true
	rm -rf /tmp/odoo || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 


