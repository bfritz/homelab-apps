# List recipes

tmpdir := `mktemp -d`

# List all recipes
@default:
    just --list

# Run all lint tasks
lint: lint_apps_yaml lint_helm lint_kustomize lint_dashboards

# Lint apps.yaml
lint_apps_yaml:
    @echo "Linting apps.yaml ..."
    @yq e < apps.yaml > /dev/null

# Lint Helm charts
lint_helm:
    @for app in `find apps -name Chart.yaml | xargs dirname | sort`; do \
        echo "Linting $app (helm) ..."; \
        (tmpdir=$(mktemp -d) && helm dependency update "$app" > /dev/null && helm lint "$app" > /dev/null && rm -r $tmpdir) || exit 1; \
    done

# Lint Kustomize manifests
lint_kustomize:
    @for app in `find apps -name kustomization.yaml | grep -v '/vendor/' | xargs dirname | sort`; do \
        echo "Linting $app (kustomize)..."; \
        (tmpdir=$(mktemp -d) && kubectl kustomize -o $tmpdir "$app" && rm -rf $tmpdir) || exit 1; \
    done

# Lint Grafana dashboards
lint_dashboards:
    @for dash in `ls apps/monitoring/dashboards/*.yaml | sort`; do \
        echo "Linting dashboard $dash ..."; \
        yq e '.data[]' < "$dash" | jq . > /dev/null ; \
    done

# Extract CA cert from cert-manager
extract_certs:
    # Extract individual certs from `cluster-ca-signing-certs` secret into `cert.pem` and `cert1.pem`
    # where `cert.pem` is the intermediate and `cert1.pem` is the CA.
    @test -n "$KUBECONFIG"
    kubectl get secret -n cert-manager cluster-ca-signing-certs -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} { print > "{{tmpdir}}/cert" n ".pem"}'

# Configure ArgoCD to trust gitlab.k8s server certificate
argocd_trust_gitlab_cert: extract_certs
    -kubectl delete configmap -n argocd argocd-tls-certs-cm
    kubectl create configmap -n argocd argocd-tls-certs-cm \
        --from-file=gitlab.k8s={{tmpdir}}/cert1.pem

# Use $SOPS_AGE_KEY to decrypt all .enc files and apply to kubernetes
sops_apply_secrets:
    @test -n "$KUBECONFIG"
    @test -n "$SOPS_AGE_KEY"
    find apps -name '*.yaml.enc' -execdir sh -c 'sops --decrypt --input-type=yaml --output-type=yaml {} | kubectl apply -f -' \;

# Encrypt {{file}}.sensitive into {{file}}.enc using $SOPS_AGE_KEY
sops_encrypt file:
    @test -n "$SOPS_AGE_KEY"
    sops --encrypt --encrypted-regex '^(data|stringData|tls.crt|tls.key)$' \
        --input-type yaml --output-type yaml \
        --age="age16a2rje3pq2hns5g2dnd0nnwxu5rkam4885mk2hfcr0fs2v8444dqqjrtl9" \
        {{file}}.sensitive > {{file}}.enc

# Decrypt all `.enc` files into `.sensitive` files using $SOPS_AGE_KEY
sops_decrypt_all:
    @test -n "$SOPS_AGE_KEY"
    @for enc in `find apps -name '*.yaml.enc' | sort`; do \
        echo "Decrypting $enc ..."; \
        sops --decrypt --input-type=yaml --output-type=yaml "$enc" > "${enc%%.enc}.sensitive"; \
    done

# Delete all decrypted secrets with `.sensitive` extensions
clean:
    @find apps -name '*.sensitive' -execdir rm {} \;
