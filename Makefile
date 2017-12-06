benchmark:
	@docker-compose -f ./benchmarks/docker-compose.yml build
	@docker-compose -f ./benchmarks/docker-compose.yml run benchmark
