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
RUN sh -c "git clone https://github.com/eclipse/paho.mqtt.c.git \
    && cd paho.mqtt.c \
    && git checkout v1.3.8 \
    && cmake -Bbuild -H. -DPAHO_ENABLE_TESTING=OFF -DPAHO_BUILD_STATIC=ON -DPAHO_WITH_SSL=OFF -DPAHO_HIGH_PERFORMANCE=ON \
    && cmake --build build/ --target install \
    && ldconfig"
RUN sh -c "git clone https://github.com/eclipse/paho.mqtt.cpp \
    && cd paho.mqtt.cpp \
    && cmake -Bbuild -H. -DPAHO_BUILD_STATIC=ON -DPAHO_BUILD_DOCUMENTATION=FALSE -DPAHO_BUILD_SAMPLES=FALSE -DPAHO_WITH_SSL=OFF \
    && cmake --build build/ --target install \
    && ldconfig"


RUN sh -c "mkdir /app \
    && mkdir /app/generated"

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
RUN make -f Makefile Erzeuger


###
### Run Stage
###
FROM ubuntu:latest

# Install mqtt dependencies
RUN apt-get update -y && apt-get install -y wget make gcc g++ git curl build-essential
RUN sh -c "mkdir -p /usr/opt \
    && cd /usr/opt \
    && curl -s -L https://github.com/Kitware/CMake/releases/download/v3.19.2/cmake-3.19.2-Linux-x86_64.sh -o cmake.sh \
    && sh cmake.sh --skip-license --prefix=/usr/local"
RUN sh -c "git clone https://github.com/eclipse/paho.mqtt.c.git \
    && cd paho.mqtt.c \
    && git checkout v1.3.8 \
    && cmake -Bbuild -H. -DPAHO_ENABLE_TESTING=OFF -DPAHO_BUILD_STATIC=ON -DPAHO_WITH_SSL=OFF -DPAHO_HIGH_PERFORMANCE=ON \
    && cmake --build build/ --target install \
    && ldconfig"
RUN sh -c "git clone https://github.com/eclipse/paho.mqtt.cpp \
    && cd paho.mqtt.cpp \
    && cmake -Bbuild -H. -DPAHO_BUILD_STATIC=ON -DPAHO_BUILD_DOCUMENTATION=FALSE -DPAHO_BUILD_SAMPLES=FALSE -DPAHO_WITH_SSL=OFF \
    && cmake --build build/ --target install \
    && ldconfig"

# Copy the exec
COPY --from=buildStage /app/build/Erzeuger /app/

# Start the app
WORKDIR /app
ENTRYPOINT ["./Erzeuger"]
CMD ["ip=127.0.0.1", "port=5000"]
