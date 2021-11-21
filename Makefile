.PHONY: \
	lint \
	__end

kustomize_apps = $(sort $(dir $(wildcard apps/*/kustomization.yaml)))
grafana_dashboards = $(sort $(wildcard apps/monitoring/dashboards/*.yaml))


lint:
	@echo Linting apps.yaml ...
	@yq e < apps.yaml > /dev/null
	@for app in $(kustomize_apps); do \
		echo Linting $$app ...; \
		tmpdir=$$(mktemp -d); \
		kubectl kustomize -o $$tmpdir $$app; \
		rm -rf $$tmpdir; \
	done
	@for dashboard in $(grafana_dashboards); do \
		echo Linting dashboard $$dashboard ...; \
                yq e '.data[]' $$dashboard | jq . > /dev/null; \
	done


__end:
