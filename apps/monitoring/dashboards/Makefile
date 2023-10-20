.PHONY: update

update:
	@echo Downloading icmp-exporter
	@curl -Ls "https://gitlab.com/anarcat/grafana-dashboards/-/raw/master/icmp-exporter.json?inline=false" | ./to_yaml.sh icmp-exporter.yaml
	@echo Downloading blackbox-exporter-http-prober
	@curl -Ls "https://grafana.com/api/dashboards/13659/revisions/1/download" | ./to_yaml.sh blackbox-exporter-http-prober.yaml
