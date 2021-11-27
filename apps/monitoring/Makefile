gotify-admin-password.yaml:
	$(info Use `kubectl -n monitoring get secret gotify-admin -ojson | jq -r '.data.password' | base64 -d` to retrieve password.)
	openssl rand -base64 15 \
		| kubectl create secret generic -n monitoring gotify-admin --dry-run=client --from-file=password=/dev/stdin -o json \
		| kubeseal --format yaml \
		> gotify-admin-password.yaml
