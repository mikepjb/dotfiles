grab:
	go run grab.go

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

upload:
	docker tag hypalynx/box registry.hub.docker.com/hypalynx/box
	docker push registry.hub.docker.com/hypalynx/box

# Homelab

homelab:
	minikube start
