NAME = trentgardner/postfix-relay

all:: build

build:
	docker build --rm --tag=$(NAME) .

shell:
	docker run --interactive --rm --tty $(NAME) /bin/bash