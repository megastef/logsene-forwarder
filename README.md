
docker run -d -p 1514:514 -p 10000:10000 --name lgslog -e LOGSENE_TOKEN=YOUR_APP_TOKEN sematext/logsene-logger

tail -f /var/log/messages | netcat localhost 1514



