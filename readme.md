
# TODO

- SSL, including enabling it on dina realm
- CORS
- i18n
- Export keycloak basic settings as dump
- Organize CSS better
- 2017-10-24T14:20:31.877149Z 0 [Note] InnoDB: page_cleaner: 1000ms intended loop took 1949304ms. The settings might not be optimal. (flushed=0 and evicted=0, during the time.)

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

Create a realm "dina" and enable it. Settings for the realm:

- http://localhost:8080/auth/admin/master/console/#/realms/dina/login-settings
   - Enable
      - User registration 
      - Email as username 
      - Edit username 
      - Forgot password 
      - Remember Me 
      - Verify email 
      - Login with email 
   - Set SSL as required
- http://localhost:8080/auth/admin/master/console/#/realms/dina/smtp-settings
   - Set dmail settings here
- http://localhost:8080/auth/admin/master/console/#/realms/dina/theme-settings
   - Select dina theme for all services where it it available
- http://localhost:8080/auth/admin/master/console/#/realms/dina/roles
   - Add role "dinaadmin"

Create users
- User to manage users within the dina realm:
    - useradmin / pwd
    - Add role mappings for Client role "realm-management": manage-user, query-users, view-users


For developing the themes, disable caching like so:

        <staticMaxAge>-1</staticMaxAge>
        <cacheThemes>false</cacheThemes>
        <cacheTemplates>false</cacheTemplates>

For production, ensable caching:

        <staticMaxAge>2592000</staticMaxAge>
        <cacheThemes>true</cacheThemes>
        <cacheTemplates>true</cacheTemplates>


## SSL

    -e SSL_EXPIRE=365 \
    -e CA_EXPIRE=365 \

# JS

create client, access type public
configure valid redirect URIs and valid web origins

