#!/bin/bash
echo "ENTRYPOINT SCRIPT"
: ${KEYCLOAK_URL:=keycloak.example.com}
REALM=keypress
echo "URL = $KEYCLOAK_URL"

sed -i "s|KEYPRESS_URL|$KEYPRESS_URL|g" /usr/src/keypress/keycloak/keypress-realm.json
sed -i "s|KEYCLOAK_URL|$KEYCLOAK_URL|g" /usr/src/keypress/keycloak.json
sed -i "s|KEYCLOAK_URL|$KEYCLOAK_URL|g" /usr/src/keypress/keycloak/admin-client.json

REALM_POST=$(cat /usr/src/keypress/keycloak/keypress-realm.json)
USER_POST=$(cat /usr/src/keypress/keycloak/keypress-users-0.json)
TKN=$(curl -X POST "$KEYCLOAK_URL/auth/realms/master/protocol/openid-connect/token" \
                  -H "Content-Type: application/x-www-form-urlencoded" \
                  -d "username=admin" \
                  -d 'password=admin' \
                  -d 'grant_type=password' \
                  -d 'client_id=admin-cli' | grep -Po '"access_token":.*?[^\\]",' | cut -d':' -f2 | sed 's/\"//g' | sed 's/,//g')

curl -vvv -X POST "$KEYCLOAK_URL/auth/admin/realms/" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $TKN" \
                  -d "$REALM_POST"
set -x
curl -vvv -X POST "$KEYCLOAK_URL/auth/admin/realms/$REALM/partialImport" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $TKN" \
                  -d "$USER_POST"

npm start
