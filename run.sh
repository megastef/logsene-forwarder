#!/bin/bash
set -e
	
if [ $1 == "service" ]; then
	# TCP Input lines
	export TCP_LINE_INPUT="input://tcp://0.0.0.0:10000"
	export GROK_LINE="filter://grok://?grok=%{GREEDYDATA:message}" 
	export LOGSENE_OUTPUT="output://elasticsearch://logsene-receiver.sematext.com:443?index_name=${LOGSENE_TOKEN}&ssl=true&bulk_size=100&bulk_time=500"

	echo listening on TCP 10000 for text input
	echo node-logstash-agent $TCP_LINE_INPUT $GROK_LINE $LOGSENE_OUTPUT &
	node-logstash-agent $TCP_LINE_INPUT $GROK_LINE $LOGSENE_OUTPUT &

	export TCP_JSON_INPUT="input://tcp://0.0.0.0:10001?type=tcp_json"
	# We use bunyan as "default" fomrat, it adds all JSON fields
	# but if bunan is the input we map "msg" and "time" to "message" / "@timestamp"
	export TCP_JSON_FILTER="filter://bunyan://"
	export TCP_JSON_FILTER2="filter://compute_field://message?value=#{msg} filter://compute_field://@timestamp?value=#{time}"

	echo node-logstash-agent $TCP_JSON_INPUT $TCP_JSON_FILTER $TCP_JSON_FILTER2 $LOGSENE_OUTPUT &
	node-logstash-agent $TCP_JSON_INPUT $TCP_JSON_FILTER $TCP_JSON_FILTER2 $LOGSENE_OUTPUT &

	echo listening on TCP 514 for syslog input
	export SYSLOG_TCP_INPUT="input://tcp://0.0.0.0:514?type=syslog"
	export SYSLOG_FILTERS="filter://regex://syslog?only_type=syslog filter://syslog_pri://?only_type=syslog filter://geoip://host filter://reverse_dns://host"
	echo node-logstash-agent $SYSLOG_TCP_INPUT $SYSLOG_FILTERS $LOGSENE_OUTPUT &
	node-logstash-agent $SYSLOG_TCP_INPUT $SYSLOG_FILTERS $LOGSENE_OUTPUT 
fi	

if [ $1 == "json" ]; then 
	node-logstash-agent input://stdin:// $TCP_JSON_FILTER TCP_JSON_FILTER2 $LOGSENE_OUTPUT
else 
	node-logstash-agent input://stdin:// $GROK_LINE $LOGSENE_OUTPUT
fi


