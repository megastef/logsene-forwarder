#!/bin/bash
set -e
# Expect ENV var LOGSENE_TOKEN !!!

if [ "$1" == "service" ]; then
	# TCP Input lines
	export TCP_LINE_INPUT="input://tcp://0.0.0.0:10000"
	export GROK_LINE="filter://grok://?grok=%{GREEDYDATA:message}" 
	export LOGSENE_OUTPUT="output://elasticsearch://logsene-receiver.sematext.com:443?index_name=${LOGSENE_TOKEN}&ssl=true&bulk_size=100&bulk_time=100"

	echo listening on TCP 10000 for text input
	echo node-logstash-agent $TCP_LINE_INPUT $GROK_LINE $LOGSENE_OUTPUT &
	node-logstash-agent --http_max_sockets 1 $TCP_LINE_INPUT $GROK_LINE $LOGSENE_OUTPUT &

	export TCP_JSON_INPUT="input://tcp://0.0.0.0:10001?type=tcp_json"
	# We use bunyan as "default" format, it adds all JSON fields
	# but if bunyan is the input we map "msg" and "time" to "message" / "@timestamp"
	export TCP_JSON_FILTER="filter://bunyan://"
	export TCP_JSON_FILTER2="filter://compute_field://message?value=#{msg} filter://compute_field://@timestamp?value=#{time}"

	node-logstash-agent --http_max_sockets 1 $TCP_JSON_INPUT $TCP_JSON_FILTER $TCP_JSON_FILTER2 $LOGSENE_OUTPUT &

	echo listening on UDP 514 for syslog input
	export SYSLOG_UDP_INPUT="input://udp://0.0.0.0:514?type=syslog"
	export SYSLOG_FILTERS="filter://regex://syslog?only_type=syslog filter://syslog_pri://?only_type=syslog"
	node-logstash-agent --http_max_sockets 1  $SYSLOG_TCP_INPUT $SYSLOG_FILTERS $LOGSENE_OUTPUT 
fi	

if [ "$1" == "json" ]; then 
	node-logstash-agent input://stdin:// $TCP_JSON_FILTER $TCP_JSON_FILTER2 $LOGSENE_OUTPUT
else 
	node-logstash-agent input://stdin:// $GROK_LINE $LOGSENE_OUTPUT
fi


