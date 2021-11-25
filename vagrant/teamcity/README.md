docker run -itd --name teamcity-server \
-v teamcity_data:/data/teamcity_server/datadir \
-v teamcity_logs:/opt/teamcity/logs \
-p 8111:8111 \
jetbrains/teamcity-server


docker run -itd \
-v teamcity_agent_conf:/data/teamcity_agent/conf  \
-e SERVER_URL="http://192.168.70.101:8111"  \
jetbrains/teamcity-agent

docker run -itd \
-v teamcity_agent_conf:/data/teamcity_agent/conf  \
-e SERVER_URL="http://192.168.70.101:8111"  \
-v /var/run/docker.sock:/var/run/docker.sock  \
-v /usr/local/bin/docker:/usr/local/bin/docker  \
jetbrains/teamcity-agent

