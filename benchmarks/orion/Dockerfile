FROM crystallang/crystal:latest

WORKDIR /app
ADD app.cr shard.yml ./
RUN shards build --release

CMD ./orion
