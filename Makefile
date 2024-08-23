build:
	docker build -t hypalynx/box --target=box .

test:
	docker run --detach-keys='ctrl-t,t' --rm -it hypalynx/box /bin/bash
