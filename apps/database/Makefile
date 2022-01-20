TWO_YEARS_IN_H = $(shell echo $$((2 * 24 * 365)))
ONE_MONTH_IN_H = $(shell echo $$((31 * 24)))

.PHONY: all
all: templates/pg12-creds.yaml templates/pg12-certs.yaml

templates/pg12-creds.yaml:
	$(info Use `kubectl -n database get secret pg12-creds -ojson | jq -r '.data."postgresql-password"' | base64 -d` to retrieve password.)
	openssl rand -base64 15 \
		| kubectl create secret generic -n database pg12-creds --dry-run=client --from-file=postgresql-password=/dev/stdin -o json \
		| kubeseal --format yaml \
		> templates/pg12-creds.yaml

templates/pg12-certs.yaml:
	$(info Creating pg12 server cert and postgres client cert.)
	$(info Use `kubectl -n database get secret pg12-certs -ojson | jq -rs` to view certificates.)
	$(info e.g. `kubectl -n database get secret pg12-certs -ojson | jq -r '.data."postgres.crt"' | base64 -d | tee /tmp/postgres.crt` .)
ifndef ROOT_CA
$(error ROOT_CA is not set)
endif
ifndef STEP_CA
$(error STEP_CA is not set)
endif
ifndef STEP_CA_KEY
$(error STEP_CA_KEY is not set)
endif
	tmpdir=$$(mktemp -d) && \
	step certificate create pg12 $$tmpdir/pg12.crt $$tmpdir/pg12.key \
		--ca="$(STEP_CA)" --ca-key="$(STEP_CA_KEY)" \
		--not-before=-1h --not-after=$(TWO_YEARS_IN_H)h \
		--no-password --insecure && \
	step certificate bundle $$tmpdir/pg12.crt "$(STEP_CA)" $$tmpdir/pg12_chain.crt && \
	step certificate create postgres $$tmpdir/postgres.crt $$tmpdir/postgres.key \
		--ca="$(STEP_CA)" --ca-key="$(STEP_CA_KEY)" \
		--not-before=-1h --not-after=$(ONE_MONTH_IN_H)h \
		--no-password --insecure && \
	step certificate bundle $$tmpdir/postgres.crt "$(STEP_CA)" $$tmpdir/postgres_chain.crt && \
	kubectl create secret generic -n database pg12-certs --dry-run=client -o json \
		--from-file=ca.crt="$(ROOT_CA)" \
		--from-file=pg12.crt=$$tmpdir/pg12_chain.crt \
		--from-file=pg12.key=$$tmpdir/pg12.key \
		--from-file=postgres.crt=$$tmpdir/postgres_chain.crt \
		--from-file=postgres.key=$$tmpdir/postgres.key \
		| kubeseal --format yaml \
                > templates/pg12-certs.yaml ; \
	rm -r $$tmpdir
