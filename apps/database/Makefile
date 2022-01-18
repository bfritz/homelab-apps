templates/pg12-creds.yaml:
	$(info Use `kubectl -n database get secret pg12-creds -ojson | jq -r '.data."postgresql-password"' | base64 -d` to retrieve password.)
	openssl rand -base64 15 \
		| kubectl create secret generic -n database pg12-creds --dry-run=client --from-file=postgresql-password=/dev/stdin -o json \
		| kubeseal --format yaml \
		> templates/pg12-creds.yaml
