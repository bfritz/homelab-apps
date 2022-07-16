# For decrypting the sops `.enc` files, populate key with:
#
#     export SOPS_AGE_KEY=$(age -d [path_to_passphrase_protected_sops_key])


.PHONY: \
	show-gotify-admin-password \
        __end

show-gotify-admin-password:
	ifndef KUBECONFIG
	$(error KUBECONFIG is not set)
	endif
	@kubectl -n monitoring get secret gotify-admin -ojson | jq -r '.data.password' | base64 -d

gotify-admin-password.yaml.sensitive:
	openssl rand -base64 15 \
		| kubectl create secret generic -n monitoring gotify-admin --dry-run=client --from-file=password=/dev/stdin -o yaml > $@

gotify-admin-password.yaml.enc: gotify-admin-password.yaml.sensitive
	sops --encrypt --age="age16a2rje3pq2hns5g2dnd0nnwxu5rkam4885mk2hfcr0fs2v8444dqqjrtl9" --encrypted-regex '^data' $< > $@

__end:
