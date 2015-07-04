FROM iojs:2.3
RUN apt-get install git -y 
# RUN apt-get install libzmq-dev
RUN apt-get install git -y
RUN git clone https://github.com/megastef/node-logstash.git
WORKDIR node-logstash
RUN npm i -g 
WORKDIR /
ADD ./run.sh /bin/logsene
RUN chmod +x /bin/logsene
EXPOSE 10000 10001 514
ENTRYPOINT ["logsene"]
CMD ["service"]
