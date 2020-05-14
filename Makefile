TARGETS = minimal prefix commondeps

all: $(TARGETS)

$(TARGETS): %: Dockerfile
	docker build --target $@ --build-arg makewidth=4 -t w1xm/pybombs/pybombs-$@ .
