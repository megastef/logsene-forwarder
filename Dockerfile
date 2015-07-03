FROM iojs:onbuild
RUN apt-get install git -y 
RUN apt-get install libzmq1
RUN git clone https://github.com/bpaquet/node-logstash.git
WORKDIR node-logstash
RUN npm i -g 
ADD ./run.sh /run.sh
RUN chmod +x /run.sh
EXPOSE tcp:9000
EXPOSE tcp:514
EXPOSE udp:514
ENTRYPOINT  ["/run.sh server"]
