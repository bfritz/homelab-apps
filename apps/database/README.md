# database

## Recipes

### Connecting to pg12 as `postgres` superuser

```sh
for F in ca.crt postgres.crt postgres.key; do
    echo Fetching $F from kubernetes secret ...
    kubectl -n database get secret pg12-certs -ojson | jq -r ".data.\"$F\"" | base64 -d > /tmp/$F
done
chmod 600 /tmp/postgres.key

kubectl -n database port-forward service/app-database-pg12 5444:5432 &

PGSSLMODE=require \
PGSSLROOTCERT=/tmp/ca.crt \
PGSSLCERT=/tmp/postgres.crt \
PGSSLKEY=/tmp/postgres.key \
PGHOST=localhost \
PGPORT=5444 \
PGUSER=postgres \
psql 
```
