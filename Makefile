benchmark:
	@rm -f benchmarks/results.txt
	@docker-compose -f ./benchmarks/docker-compose.yml build
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark-http
	@docker-compose -f ./benchmarks/docker-compose.yml stop
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark-kemal
	@docker-compose -f ./benchmarks/docker-compose.yml stop
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark-orion
	@docker-compose -f ./benchmarks/docker-compose.yml stop
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark-orion-old
	@docker-compose -f ./benchmarks/docker-compose.yml stop
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark-sinatra
	@docker-compose -f ./benchmarks/docker-compose.yml stop
	# @docker-compose -f ./benchmarks/docker-compose.yml run benchmark-express
	# @docker-compose -f ./benchmarks/docker-compose.yml stop
	# @docker-compose -f ./benchmarks/docker-compose.yml run benchmark-http-router
	# @docker-compose -f ./benchmarks/docker-compose.yml stop
