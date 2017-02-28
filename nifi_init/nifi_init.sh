#!/bin/bash
NIFI_HOST="${NIFI_HOST:-nifi}"
NIFI_PORT="${NIFI_PORT:-8080}"
NIFI_URL_BASE_ROOT="${NIFI_URL_BASE_ROOT:-/nifi-api}"
NIFI_URL_BASE="http://${NIFI_HOST}:${NIFI_PORT}${NIFI_URL_BASE_ROOT}"

echo "Waiting for Nifi API to become available..."
while ! curl -s ${NIFI_URL_BASE} >/dev/null; do
  echo -n '.'
  sleep 0.5
done
echo "Nifi API now available"

for template_file in nifi_templates/*.xml
do
  echo "Uploading ${template_file} template..."
  curl -s -F "template=@${template_file}"  \
    "${NIFI_URL_BASE}/process-groups/root/templates/upload"
done

echo "Finding template id for consume-and-debug template..."
consume_and_debug_templ_id=$(curl -s "${NIFI_URL_BASE}/flow/templates" \
  |jq -r '.templates[] | select (.template.name=="consume-and-debug") | .id')
echo "Template id: ${consume_and_debug_templ_id}"

echo "Attempting to instantiate consume-and-debug template..."
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"templateId":'"\"${consume_and_debug_templ_id}\""',"originX": 0.0,"originY": 0.0}' \
  -o /dev/null "${NIFI_URL_BASE}/process-groups/root/template-instance"
