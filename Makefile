
NAME = madharjan/docker-odoo
VERSION = 9.0

.PHONY: all build run tests clean tag_latest release clean_images

all: build

build:
	docker build \
		--build-arg ODOO_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=true \
		-t $(NAME):$(VERSION) --rm .

run:
	rm -rf /tmp/odoo
	mkdir -p /tmp/odoo/etc/
	mkdir -p /tmp/odoo/addons/
	mkdir -p /tmp/odoo/lib/

	docker run -d \
		-e POSTGRESQL_USERNAME=odoo \
		-e POSTGRESQL_PASSWORD=odoo \
		--name odoo-postgresql madharjan/docker-postgresql:9.3

	sleep 2

	docker run -d \
		-e POSTGRESQL_USERNAME=odoo \
		-e POSTGRESQL_PASSWORD=odoo \
		--name odoo-postgresql_default madharjan/docker-postgresql:9.3

	sleep 5

	docker run -d \
		--link odoo-postgresql:postgresql \
		-e ODOO_DATABASE_NAME=odoo \
	  -e ODOO_ADMIN_PASSWORD=Pa55w0rd \
	  -e ODOO_ADMIN_EMAIL=admin@local.host \
	  -e ODOO_COMPANY="Acme Pte Ltd" \
	  -e ODOO_INSTALL_MODULES="website" \
	  -e ODOO_LANG=en_US \
	  -p 8080:8069 \
	  -v /tmp/odoo/etc:/etc/odoo \
	  -v /tmp/odoo/addons:/opt/odoo/extra \
	  -v /tmp/odoo/lib:/var/lib/odoo \
		-e DEBUG=true \
		--name odoo $(NAME):$(VERSION)

	sleep 5

	docker run -d \
	  --link odoo-postgresql:postgresql \
		-e DISABLE_ODOO=1 \
		-e DEBUG=true \
	  --name odoo_no_odoo $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		--link odoo-postgresql_default:postgresql \
		-e DEBUG=true \
		--name odoo_default $(NAME):$(VERSION)

	sleep 5

tests:
	sleep 4
	./bats/bin/bats test/tests.bats

clean:
	docker exec odoo /bin/bash -c "sv stop odoo" || true
	sleep 6
	docker exec odoo /bin/bash -c "rm -rf /etc/odoo/*" || true
	docker exec odoo /bin/bash -c "rm -rf /var/lib/odoo/*" || true
	docker stop odoo odoo_no_odoo odoo_default odoo-postgresql odoo-postgresql_default || true
	docker rm odoo odoo_no_odoo odoo_default odoo-postgresql odoo-postgresql_default || true
	rm -rf /tmp/odoo || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -X POST https://hooks.microbadger.com/images/madharjan/docker-odoo/hC0t5pCAhU_wM_ayM-hNsk72vak=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
