###
### Build Stage
###
FROM ubuntu:latest AS buildStage

LABEL stage = build

# Update all apps and install build deps
RUN apt-get update -y && apt-get install -y wget make gcc g++ git curl build-essential
RUN sh -c "mkdir -p /usr/opt \
    && cd /usr/opt \
    && curl -s -L https://github.com/Kitware/CMake/releases/download/v3.19.2/cmake-3.19.2-Linux-x86_64.sh -o cmake.sh \
    && sh cmake.sh --skip-license --prefix=/usr/local"

# Copy the app
COPY src/ /app/src
COPY CMakeLists.txt /app

# Start build process
WORKDIR /app/build
RUN cmake -B . ../
RUN make -f Makefile LoadBalancer

###
### Run Stage
###
FROM ubuntu:latest

# Copy the exec
COPY --from=buildStage /app/build/LoadBalancer /app/

# Mark ports to be exposed
EXPOSE 10000

# Start the app
WORKDIR /app
ENTRYPOINT ["./LoadBalancer"]
CMD ["sourcePort=10000", "targetPort=9000", "zentrale1=127.0.0.1"]
