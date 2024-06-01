.PHONY: help build clean

help:
	@echo "Commands: make [clean | build ]";

build:
	-make -j build_zentrale build_verbraucher build_erzeuger build_energieversorger build_loadbalancer
build_zentrale:
	-docker build -t zentrale4:latest Zentrale/
build_erzeuger:
	-docker build -t erzeuger4:latest Erzeuger/
build_verbraucher:
	-docker build -t verbraucher4:latest Verbraucher/
build_loadbalancer:
	-docker build -t loadbalancer4:latest LoadBalancer/
build_energieversorger:
	-docker build -t energieversorger4:latest Energieversorger/


clean:
	-docker image rm zentrale
	-docker image rm verbraucher
	-docker image rm erzeuger
	-docker image rm energieversorger
	-docker image rm loadbalancer
