Keycloak docker-compose setup with
- UI customized for DINA
- MySQL database
- nginx reverse proxy with self-signed certificates

# Notes

- Emails don't always arrive when using dmail.
- Keycloak 3.2.1 has a bug that prevents user from changing their data if email is used as a username. Should be fixed later, see https://issues.jboss.org/browse/KEYCLOAK-5443?attachmentOrder=asc&_sscc=t
- Keycloak has a bug that prevents deleting groups (internal server error, nullPointerException). Should be fixed later, see https://issues.jboss.org/browse/KEYCLOAK-5268
- Modifying the **admin console theme** styles is somewhat difficult, because that requires creating a new theme, which in turn prevents some css from loading. Documentation is not comprehensive on this issue. Including these styles will make user management components work: `node_modules/select2/select2.css css/styles.css`. Modifying login and account themes work fine.
- nginx-proxy container caches the certificates, so changing them after they have been loaded has no effect, unless container is deleted and recreated. (WARNING: Service "nginx-proxy" is using volume "/etc/nginx/certs" from the previous container. Host mapping "NNN" has no...). Is this normal Docker or nginx-proxy behavior?

# Setup

## For local development

- Add these urls to `/etc/hosts`:
   - `accounts.dina-web.local keycloak.accounts.dina-web.local`
- Create certs using `make create-certs`. Import the generated self-signed certificate authority file `ca.pem` to your browser
- Start the services with `docker-compose up`
- Set up Keycloak settings using the Admin console at https://keycloak.accounts.dina-web.local
- Access URLs:
   - Login to the dina realm at http://keycloak.accounts.dina-web.local/auth/realms/dina/account
   - Keycloak Admin Console: https://keycloak.accounts.dina-web.local
   - Demonstration UI with nginx and JavaScript: https://accounts.dina-web.local

# For centralized instance

- Add URL(s) to docker-compose.yml
- Setup proxy, remove local proxy from docker-compose.yml
- Start the services with `docker-compose up`
- Set up Keycloak settings using the Admin console at https://keycloak.accounts.dina-web.local
- For better performance, enable theme caching (see below)

# Keycloak settings 

Keycloak has a tool to export/import realm settings, but that doesn't seem to work reliably. Example export is at keycloak/realm-export.json

Terms:

- Realm: Entity that contains all settings for one project, in our case for all of DINA
- Client: an application that uses Keycloak for authentication. E.g. the collections management module

## Basic settings

### dina realm

Create a realm "dina" and enable it. Settings for the realm:

- General
   - Enable
      - User registration 
      - Edit username 
      - Forgot password 
      - Remember Me 
      - Verify email 
      - Login with email 
   - Disable
      - Email as username 
   - Require SSL: all requests
- Email
   - Set dmail settings here
- Themes
   - Select dina theme for all services where it it available

This also automatically creates client "account", which is used for mnaging user's own information on Keycloak.

## Users

For each new user:

- Add user
- Add credential
    - password
    - Temporary: off
- Add role mapping:
    - client role: account (this enables user to login and edit their own info)
    - assigned roles: manage-account, view-profile
- **CHECK?** Add a role to the user, connect role to dina-account-test

## Client

Docker-compose file has a **demo-ui** demonstrating frontent application authenticating with Keycloak. To enable this:

- Uncomment the demo-client and start it with docker-compose
- Add `accounts.dina-web.local` to `/etc/hosts`
- Add matching client to Keycloak:
    - Client ID: dina-accounts-demo
    - Name: Keycloak authentication demo
    - Root URL: https://accounts.dina-web.local
    - Valid redirect URI's: https://accounts.dina-web.local/*
    - Base URL: https://accounts.dina-web.local
    - Web Origins: * (stricter value should be ok also)
- Access the demo at https://accounts.dina-web.local

## Possible additional settings later

**If users apart from superuser need permissions to add / modify users**, this could be done by creating a group that has permissions to do this:

- Add group "dina-user-admin-group". Add role mappings for Client role "realm-management": manage-user, view-users
- Add user to the group "dina-user-admin-group"


## Theme caching

For developing the themes, disable caching in keycloak/configuration/standalone.xml like so:

        <staticMaxAge>-1</staticMaxAge>
        <cacheThemes>false</cacheThemes>
        <cacheTemplates>false</cacheTemplates>

For production, ensable caching:

        <staticMaxAge>2592000</staticMaxAge>
        <cacheThemes>true</cacheThemes>
        <cacheTemplates>true</cacheTemplates>

# TODO

- Try Keycloak 3.0.0 - does this version have the bugs described above?
- Make sure database/settings are preserved
- Test realm import more
- i18n
- Export keycloak basic settings as dump / json?
- Organize CSS better
- Error message: 2017-10-24T14:20:31.877149Z 0 [Note] InnoDB: page_cleaner: 1000ms intended loop took 1949304ms. The settings might not be optimal. (flushed=0 and evicted=0, during the time.)
- Add params to certs?
   -e SSL_EXPIRE=365 \
   -e CA_EXPIRE=365 \

