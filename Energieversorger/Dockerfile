###
### Build Stage
###
FROM ubuntu:latest AS buildStage

LABEL stage = build

# Update all apps and install build deps
RUN apt-get update -y && apt-get install -y wget make gcc g++ git curl build-essential autoconf automake libtool pkg-config
RUN sh -c "mkdir -p /usr/opt && cd /usr/opt \
  && curl -s -L https://github.com/Kitware/CMake/releases/download/v3.19.2/cmake-3.19.2-Linux-x86_64.sh -o cmake.sh \
  && sh cmake.sh --skip-license --prefix=/usr/local"


RUN mkdir /app
RUN mkdir /app/generated
#This is the rpc stuff because fetch does not work
RUN sh -c "mkdir -p grpc  \
    && git clone --recurse-submodules -b v1.58.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc \
    && cd grpc"
RUN sh -c "ls"

RUN sh -c "cd grpc \
           mkdir -p cmake/build \
           pushd cmake/build \
           cmake -DgRPC_INSTALL=ON \
               -DgRPC_BUILD_TESTS=OFF \
               -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
               ../.. \
           make -j 4 \
           make install \
           pwd \
           popd"

RUN sh -c "ls"

# Copy the app
COPY src/ /app/src
COPY CMakeLists.txt /app

# Start build process
WORKDIR /app/build
RUN cmake -B . ../
RUN make -f Makefile grpc++_reflection
RUN make -f Makefile grpc++
RUN make -f Makefile libprotobuf
RUN make -f Makefile hw_grpc_proto
RUN make -f Makefile Energieversorger

###
### Run Stage
###
FROM ubuntu:latest

# Copy the exec
COPY --from=buildStage /app/build/Energieversorger /app/

# Start the app
WORKDIR /app
ENTRYPOINT ["./Energieversorger"]
CMD ["ip=127.0.0.1", "port=5000"]
