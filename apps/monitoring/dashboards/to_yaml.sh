#!/bin/sh

set -e

filename="$1"
name="$(basename "$filename" .yaml)"

cat <<EOF > "$filename"
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-$name
  namespace: monitoring-dashboards
  labels:
    grafana_dashboard: "1"
data:
  $name.json: |-
EOF

# shellcheck disable=SC2016
cat | sed 's/^/    / ; s/${DS_[A-Z]*}/prometheus/' >> "$filename"
echo >> "$filename"
