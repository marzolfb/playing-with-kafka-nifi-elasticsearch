go:
	HOSTNAME=$(shell hostname -f) \
		KAFKA_ADVERTISED_HOST_NAME=$(shell ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') \
		docker-compose up -d

	# ./wait_for_nifi.sh

produce:
	./produce.py

debug:
	docker-compose logs -f debug

clean:
	docker-compose rm -f

# http://air.ghost.io/kibana-4-export-and-import-visualizations-and-dashboards/
dump_kibana_viz:
	elasticdump \
		--input=http://localhost:9200/.kibana  \
		--output=$ \
		--type=data \
		--searchBody='{"filter": { "or": [ {"type": {"value": "dashboard"}}, {"type" : {"value":"visualization"}}] }}' \
		> kibana-exported.json

load_kibana_viz:
	elasticdump \
		--input=kibana-exported.json \
		--output=http://localhost:9200/.kibana \
		--type=data
