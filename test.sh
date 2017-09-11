#!/bin/sh
set -ex
KEYCLOAK_URL='keycloak-kaitlyn.172.17.0.1.nip.io'


USER_POST=$(cat /home/dymurray/keypress/keypress/keycloak/keypress-users-0.json)

TKN=$(curl -X POST "http://$KEYCLOAK_URL/auth/realms/master/protocol/openid-connect/token" \
                  -H "Content-Type: application/x-www-form-urlencoded" \
                  -d "username=admin" \
                  -d 'password=admin' \
                  -d 'grant_type=password' \
                  -d 'client_id=admin-cli' | grep -Po '"access_token":.*?[^\\]",' | cut -d':' -f2 | sed 's/\"//g' | sed 's/,//g')

curl -vvv -X POST "http://$KEYCLOAK_URL/auth/admin/realms/keypress/partialImport" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $TKN" \
                  -d "$USER_POST"


