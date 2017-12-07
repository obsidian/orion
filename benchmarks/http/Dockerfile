FROM crystallang/crystal:0.23.1

WORKDIR /app
ADD app.cr shard.yml ./
RUN shards build --release --no-debug

CMD ./bin/http
