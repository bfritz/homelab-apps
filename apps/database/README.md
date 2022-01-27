# database

## Recipes

### Connecting to pg12 as `postgres` superuser

```sh
for F in ca.crt tls.crt tls.key; do
    O=$(echo $F | sed 's/tls/postgres/')
    echo Fetching $O from kubernetes secret ...
    kubectl -n database get secret pg12-postgres-cert -ojson | jq -r ".data.\"$F\"" | base64 -d > /tmp/$O
done
chmod 600 /tmp/postgres.key

kubectl -n database port-forward service/app-database-pg12 6432:6432 &
sleep 2

PGSSLMODE=require \
PGSSLROOTCERT=/tmp/ca.crt \
PGSSLCERT=/tmp/postgres.crt \
PGSSLKEY=/tmp/postgres.key \
PGHOST=localhost \
PGPORT=6432 \
PGUSER=postgres \
psql 
```
