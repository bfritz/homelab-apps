# For decrypting the sops `.enc` files, populate key with:
#
#     export SOPS_AGE_KEY=$(age -d [path_to_passphrase_protected_sops_key])


TWO_YEARS_IN_H = $(shell echo $$((2 * 24 * 365)))
ONE_MONTH_IN_H = $(shell echo $$((31 * 24)))

.PHONY: \
	show-postgresql-password \
	__end

show-postgresql-password:
	ifndef KUBECONFIG
	$(error KUBECONFIG is not set)
	endif
	@kubectl -n database get secret pg12-creds -ojson | jq -r '.data."postgresql-password"' | base64 -d

pg12-creds.yaml.sensitive:
	openssl rand -base64 15 \
		| kubectl create secret generic -n database pg12-creds --dry-run=client --from-file=postgresql-password=/dev/stdin -o yaml \
		> pg12-creds.yaml.sensitive

pg12-creds.yaml.enc: pg12-creds.yaml.sensitive
	sops --encrypt --age="age16a2rje3pq2hns5g2dnd0nnwxu5rkam4885mk2hfcr0fs2v8444dqqjrtl9" --encrypted-regex '^data' \
		pg12-creds.yaml.sensitive \
		> pg12-creds.yaml.enc

__end:
