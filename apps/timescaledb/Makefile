postgres-admin-password.yaml:
	$(info Use `kubectl -n timescaledb get secret postgres-admin -ojson | jq -r '.data.password' | base64 -d` to retrieve password.)
	openssl rand -base64 15 \
		| kubectl create secret generic -n timescaledb postgres-admin --dry-run=client --from-file=password=/dev/stdin -o json \
		| kubeseal --format yaml \
		> postgres-admin-password.yaml
