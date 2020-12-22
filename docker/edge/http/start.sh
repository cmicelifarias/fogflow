if [ $# -eq 0 ]; then
	htype='3.0'
else
	htype='arm'
fi

sh $(pwd)/script.sh
if [ $? -eq 0 ]; then
    docker run -d   --name=metricbeat   --user=root   --volume="$(pwd)/metricbeat.docker.yml:/usr/share/metricbeat/metricbeat.yml:ro"   --volume="/var/run/docker.sock:/var/run/docker.sock:ro"   --volume="/sys/fs/cgroup:/hostfs/sys/fs/cgroup:ro"   --volume="/proc:/hostfs/proc:ro"   --volume="/:/hostfs:ro"   docker.elastic.co/beats/metricbeat:7.6.0 metricbeat -e   -E output.elasticsearch.hosts=["<Cloud_Public_IP>:9200"]
    docker run -d --name=edgebroker -v $(pwd)/config.json:/config.json -p 8060:8060  fogflow/broker_edge
    docker run -d --name=edgeworker -v $(pwd)/config.json:/config.json -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock fogflow/worker:$htype
    docker run -d --name=pepEdge -v $(pwd)/pep-config.js:/opt/fiware-pep-proxy/config.js -p 5556:5556 fiware/pep-proxy
    #sh $(pwd)/user_addition.sh
    #docker run -d --name=Nginx -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf -v $(pwd)/user:/etc/nginx/user -p 80:80 nginx
else
      echo failed security check
fi

