.PHONY: \
	lint \
	apply_encrypted_sops_secrets \
	copy_cluster-ca_cert_to_gitlab_namespace \
	clean \
	__end

helm_apps = $(sort $(dir $(wildcard apps/*/Chart.yaml)))
kustomize_apps = $(sort $(dir $(wildcard apps/*/kustomization.yaml)))
grafana_dashboards = $(sort $(wildcard apps/monitoring/dashboards/*.yaml))


lint:
	@echo Linting apps.yaml ...
	@yq e < apps.yaml > /dev/null
	@for app in $(helm_apps); do \
		echo Linting with helm $$app ...; \
		tmpdir=$$(mktemp -d); \
		helm dependency update $$app > /dev/null; \
		helm template lint $$app --output-dir $$tmpdir > /dev/null; \
		rm -rf $$tmpdir; \
	done
	@for app in $(kustomize_apps); do \
		echo Linting with kustomize $$app ...; \
		tmpdir=$$(mktemp -d); \
		kubectl kustomize -o $$tmpdir $$app; \
		rm -rf $$tmpdir; \
	done
	@for dashboard in $(grafana_dashboards); do \
		echo Linting dashboard $$dashboard ...; \
                yq e '.data[]' $$dashboard | jq . > /dev/null; \
	done

apply_encrypted_sops_secrets:
	ifndef KUBECONFIG
	$(error KUBECONFIG is not set)
	endif
	ifndef SOPS_AGE_KEY
	$(error SOPS_AGE_KEY is not set)
	endif
	find apps -name '*.yaml.enc' -execdir sh -c 'sops --decrypt --input-type=yaml --output-type=yaml {} | kubectl apply -f -' \;


# Copy root cert used by cluster-ca issuer into gitlab-ce namespace so it can be trusted.
copy_cluster-ca_cert_to_gitlab_namespace: /tmp/cert1.pem
	ifndef KUBECONFIG
	$(error KUBECONFIG is not set)
	endif
	kubectl create secret generic -n gitlab-ce cluster-ca-root-cert \
            --from-file=cluster-ca-root.crt=$<
	kubectl delete configmap -n argocd argocd-tls-certs-cm
	kubectl create configmap -n argocd argocd-tls-certs-cm \
            --from-file=gitlab.k8s=$<

/tmp/cert1.pem:
	ifndef KUBECONFIG
	$(error KUBECONFIG is not set)
	endif
	kubectl get secret -n cert-manager cluster-ca-signing-certs -o json \
            | jq -r '.data["tls.crt"]' \
            | base64 -d \
            | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print >"/tmp/cert" n ".pem"}'


clean:
	@find apps -name '*.sensitive' -execdir rm {} \;


__end:
