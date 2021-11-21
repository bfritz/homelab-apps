.PHONY: update

update:
	@echo Downloading icmp-exporter
	@curl -Ls "https://gitlab.com/anarcat/grafana-dashboards/-/raw/master/icmp-exporter.json?inline=false" | ./to_yaml.sh icmp-exporter.yaml
