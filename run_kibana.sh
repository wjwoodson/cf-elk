#!/bin/bash

ES_URI=$(echo "${VCAP_SERVICES}" | jq -r .elasticsearch56[0].credentials.uri)
ES_URL=$(echo "${ES_URI}" | sed 's/\/\/.*@/\/\//')
ES_USER=$(echo "${ES_URI}" | sed 's/.*\/\/\(.*\):.*@.*/\1/')
ES_PW=$(echo "${ES_URI}" | sed 's/.*\/\/.*:\(.*\)@.*/\1/')

if grep ^elasticsearch.url config/kibana.yml >/dev/null ; then
	echo kibana.yml is already configured
else
	echo "elasticsearch.url: \"${ES_URL}\"" >> config/kibana.yml
	echo "server.port: \"9000\"" >> config/kibana.yml
	#echo "logging.verbose: true" >> config/kibana.yml
	echo "logging.verbose: true" >> config/kibana.yml
	echo "elasticsearch.username: \"${ES_USER}\"" >> config/kibana.yml
	echo "elasticsearch.password: \"${ES_PW}\"" >> config/kibana.yml
fi

# start the app up.  It runs on port 9000, and takes a long time to start up.
./bin/kibana &

# start up a proxy to redirect to the real app so that the healthcheck does
# not kill it because kibana takes so long to start up.
node server.js

