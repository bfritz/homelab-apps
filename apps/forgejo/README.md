# forgejo

Initialized the manifests from Helm with:

    helm template forgejo -f apps/forgejo/values.yaml oci://code.forgejo.org/forgejo-helm/forgejo --version 16.2.0 --skip-tests \
      | grep -v -e "managed-by:.*Helm" \
      > apps/forgejo/forgejo-helm-manifests.yaml
