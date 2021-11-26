.PHONY: \
	lint \
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


__end:
