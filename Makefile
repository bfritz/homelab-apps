.PHONY: \
	lint \
	__end

kustomize_apps = $(sort $(dir $(wildcard apps/*/kustomization.yaml)))

lint:
	@echo Linting apps.yaml ...
	@yq e < apps.yaml > /dev/null
	@for app in $(kustomize_apps); do \
		echo Linting $$app ...; \
		tmpdir=$$(mktemp -d); \
		kubectl kustomize -o $$tmpdir $$app; \
		rm -rf $$tmpdir; \
	done


__end:
