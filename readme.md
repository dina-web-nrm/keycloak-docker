
Keycloak docker-compose setup with MySQL database and nginx reverse proxy.

# Notes

- Emails don't always arrive when using dmail.
- Keycloak 3.2.1 has a bug that prevents user from changing their data if email is used as a username. Should be fixed in 3.4.1, see https://issues.jboss.org/browse/KEYCLOAK-5443?attachmentOrder=asc&_sscc=t
- Modifying how the admin UI styles is somewhat difficult, because that requires creating a new theme, which in turn prevents some css from loading. Documentation is not comprehensive on this issue. Including these styles will make user management components work: `node_modules/select2/select2.css css/styles.css`
- nginx-proxy container caches the certificates, so changing them after they have been loaded has no effect, unless container is deleted and recreated. (WARNING: Service "nginx-proxy" is using volume "/etc/nginx/certs" from the previous container. Host mapping "NNN" has no...). Is this normal Docker or nginx-proxy behavior?

# Setup

- Add the urls to `/etc/hosts`:
   - `accounts.dina-web.local keycloak.accounts.dina-web.local`
- Import self-signed certificate authority file `ca.pem` to your browser
- URLs:
   - nginx ui: https://accounts.dina-web.local
   - Login to the dina realm at http://keycloak.accounts.dina-web.local/auth/realms/dina/account
   - Keycloak Admin Console: https://keycloak.accounts.dina-web.local

## Keycloak settings 


### dina realm

Export / import dealm and client settings, see `keycloak/realm-export.json`

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

<!--
Add roles:
- Add role "dina-admin"
-->

Add groups:
- Add group "dina-user-admin-group"
    - Add role mappings for Client role "realm-management": manage-user, view-users

Add users:
- Add user "test-user" to manage users within the dina realm:
    - Add credential password "pwd", Temporary: off
    - Add user to group "dina-user-admin-group"

### Users

- Add user & password
- Add a role to the user, connect role to dina-account-test

### Keycloak settings

For developing the themes, disable caching like so:

        <staticMaxAge>-1</staticMaxAge>
        <cacheThemes>false</cacheThemes>
        <cacheTemplates>false</cacheTemplates>

For production, ensable caching:

        <staticMaxAge>2592000</staticMaxAge>
        <cacheThemes>true</cacheThemes>
        <cacheTemplates>true</cacheTemplates>

# TODO

- i18n
- Export keycloak basic settings as dump / json?
- Organize CSS better
- Error message: 2017-10-24T14:20:31.877149Z 0 [Note] InnoDB: page_cleaner: 1000ms intended loop took 1949304ms. The settings might not be optimal. (flushed=0 and evicted=0, during the time.)
- Add params to certs?
   -e SSL_EXPIRE=365 \
   -e CA_EXPIRE=365 \

