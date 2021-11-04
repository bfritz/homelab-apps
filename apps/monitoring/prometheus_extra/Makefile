additional-scrape-configs.yaml: prometheus-additional.yaml
	kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run=client -oyaml > additional-scrape-configs.yaml
