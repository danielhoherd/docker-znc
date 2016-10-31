NO_CACHE ?= true
NAME ?= znc

.PHONY: build
build:
	docker build --no-cache=$(NO_CACHE) -t ${USER}/znc .

.PHONY: run
run:
	docker run --restart=always -d -p 29492:6667 --name $(NAME) -v ${HOME}/.znc:/znc-data ${USER}/znc

.PHONY: debug
debug:
	docker run -it -p 29492:6667 --name $(NAME)-debug -v ${HOME}/.znc:/znc-data ${USER}/znc

start:
	docker start $(NAME)

stop:
	docker stop $(NAME)

rm: stop
	docker rm $(NAME)

clean: stop rm
	docker rmi $(NAME)

bounce: build stop rm run
