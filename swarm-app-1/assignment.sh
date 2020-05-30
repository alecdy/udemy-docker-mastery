# Set up swarm-wide overlay networks
docker network create -d overlay backend-network
docker network create -d overlay frontend-network

# Fire up database service
docker service create \
--name db \
--network backend-network \
-e POSTGRES_HOST_AUTH_METHOD=trust \
--mount type=volume,source=db-data,destination=/var/lib/postgresql/data \
postgres:9.4

# worker
docker service create \
--name worker \
--network backend-network \
--network frontend-network \
bretfisher/examplevotingapp_worker:java

# redis
docker service create \
--name redis \
--network frontend-network \
redis:3.2

# vote
docker service create \
--name voting-app \
--network frontend-network \
--publish 80:80 \
--replicas 3 \
bretfisher/examplevotingapp_vote

# result
docker service create \
--name result \
--network backend-network \
--publish 5001:80 \
bretfisher/examplevotingapp_result