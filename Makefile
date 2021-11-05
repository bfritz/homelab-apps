.PHONY: \
	lint \
	__end

kustomize_apps = $(sort $(dir $(wildcard apps/*/kustomization.yaml)))

lint: $(kustomize_apps)
	$(eval tmpdir := $(shell mktemp -d))
	$(info Linting $? ...)
	kubectl kustomize -o $(tmpdir) $?
	@rm -r $(tmpdir)


__end:
