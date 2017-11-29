#!make

PWD=$(shell pwd)
DATADIR=mysql-data
VOLUME=keycloakdocker_mysql-keycloak-accounts
#ERRORSDIR=errors
#HTMLDIR=html

all: up

.PHONY: all


create-certs:
# Add subdomains under SSL_DNS
	docker run -v /tmp/certs:/certs \
	-e SSL_SUBJECT=dina-web.local \
	-e SSL_DNS=accounts.dina-web.local,keycloak.accounts.dina-web.local \
	paulczar/omgwtfssl
	mkdir certs
	cp /tmp/certs/cert.pem certs/dina-web.local.crt
	cp /tmp/certs/key.pem certs/dina-web.local.key

show-certs:
	openssl x509 -noout -text -in certs/dina-web.local.crt

clean-certs: down
	#docker-compose down
	rm -fr certs
	sudo rm -fr /tmp/certs
	docker rm keycloakdocker_proxy_1 # Removes container which contains old certificates

up:
	@docker-compose up -d

up-prod:
	@docker-compose -f docker-compose.yml up -d

up-dev:
	@docker-compose -f docker-compose.yml.local up -d

stop:
	@docker-compose stop

rm-volume:
	@docker volume rm keycloakdocker_mysql-keycloak-accounts

down:
	@echo ""
	@echo "OBS Dont use 'docker-compose down' it will destroy your volumes"
	@echo ""

logs:
	@docker volume ls | grep mysql-keycloak-accounts
	sleep 2;
	@docker-compose logs -f --tail=20
