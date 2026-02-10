# This Makefile serves as a place to keep commands that are useful when
# maintaining the geoip app. To try it, use 'make status'.

# Show the status of the docker containers
status:
	docker-compose ps

# Start a shell in the running container
shell:
	docker-compose exec geoip bash

yolo-upgrade:
	(cd build/repo && git pull)
	docker-compose down
	docker-compose up --build -d
