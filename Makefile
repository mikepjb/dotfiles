build:
	docker build -t hypalynx/box --target=box .

test:
	docker run --detach-keys='ctrl-t,t' --rm -it hypalynx/box /bin/bash

security:
	docker run \
		--rm \
		-v trivy-cache:/root/.cache/ \
		-v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest \
		image hypalynx/box:latest
