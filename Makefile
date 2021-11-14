.PHONY: \
	lint \
	__end

kustomize_apps = $(sort $(dir $(wildcard apps/*/kustomization.yaml)))

lint:
	@for app in $(kustomize_apps); do \
		echo Linting $$app ...; \
		tmpdir=$$(mktemp -d); \
		kubectl kustomize -o $$tmpdir $$app; \
		rm -rf $$tmpdir; \
	done


__end:
