#!make

#PWD=$(shell pwd)
#HTMLDIR=html
DATADIR=mysql-data
#ERRORSDIR=errors

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

stop:
	@docker-compose stop

rm:

down:
	@docker-compose down


logs:
	@docker-compose logs -f --tail=20
