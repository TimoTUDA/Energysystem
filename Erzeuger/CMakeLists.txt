cmake_minimum_required(VERSION 3.19)

project(Erzeuger)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")

# main target
add_executable(Erzeuger src/cpp/main.cpp src/cpp/Komponente/Erzeuger.cpp src/header/Komponente/Erzeuger.h src/cpp/Komponente/Solar.cpp src/header/Komponente/Solar.h src/cpp/Komponente/Wind.cpp src/header/Komponente/Wind.h src/cpp/Komponente/Kohle.cpp src/header/Komponente/Kohle.h src/cpp/Komponente/Atom.cpp src/header/Komponente/Atom.h src/cpp/Kommunikation/ZentralenKommunikation.cpp src/header/Kommunikation/ZentralenKommunikation.h src/cpp/Kommunikation/UDPKommunikation.cpp src/header/Kommunikation/UDPKommunikation.h src/cpp/Simulator.cpp src/header/Simulator.h src/header/Kommunikation/UDPServer.h src/cpp/Kommunikation/UDPServer.cpp src/header/Kommunikation/UDPCallback.h src/cpp/Kommunikation/RpcController.cpp src/header/Kommunikation/RpcController.h src/cpp/Kommunikation/MqttKommunikation.cpp src/header/Kommunikation/MqttKommunikation.h)


# Threads
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package (Threads REQUIRED)
target_link_libraries(Erzeuger ${CMAKE_THREAD_LIBS_INIT})


#Mqtt stuff
find_package(PahoMqttCpp REQUIRED)
target_link_libraries(Erzeuger paho-mqttpp3)
target_link_libraries(Erzeuger paho-mqtt3a)
target_link_libraries(Erzeuger paho-mqtt3c)


# RPC stuff
#include(FetchContent)
#FetchContent_Declare(
#        gRPC
#        GIT_REPOSITORY https://github.com/grpc/grpc
#        GIT_TAG        v1.58.0
#)
#set(FETCHCONTENT_QUIET OFF)
#FetchContent_MakeAvailable(gRPC)
#set(ABSL_ENABLE_INSTALL ON)

# Create the rpc files
#set(_PROTOBUF_LIBPROTOBUF libprotobuf)
#set(_REFLECTION grpc++_reflection)
#set(_PROTOBUF_PROTOC $<TARGET_FILE:protoc>)
#set(_GRPC_GRPCPP grpc++)
#if(CMAKE_CROSSCOMPILING)
#    find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
#else()
#    set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:grpc_cpp_plugin>)
#endif()

# RPC stuff
message(${CMAKE_CURRENT_BINARY_DIR})
set(ABSL_ENABLE_INSTALL ON)
 add_subdirectory(../../grpc/ ${CMAKE_CURRENT_BINARY_DIR}/grpc EXCLUDE_FROM_ALL)
   message(STATUS "Using gRPC via add_subdirectory.")

   # After using add_subdirectory, we can now use the grpc targets directly from
   # this build.
   set(_PROTOBUF_LIBPROTOBUF libprotobuf)
   set(_REFLECTION grpc++_reflection)
   if(CMAKE_CROSSCOMPILING)
     find_program(_PROTOBUF_PROTOC protoc)
   else()
     set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)
   endif()
   set(_GRPC_GRPCPP grpc++)
   if(CMAKE_CROSSCOMPILING)
     find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
   else()
     set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:grpc_cpp_plugin>)
   endif()



# Proto file
get_filename_component(hw_proto "src/proto/erzeuger.proto" ABSOLUTE)
get_filename_component(hw_proto_path "${hw_proto}" PATH)

# Generated sources
set(hw_proto_srcs "${CMAKE_CURRENT_SOURCE_DIR}/generated/erzeuger.pb.cc")
set(hw_proto_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/generated/erzeuger.pb.h")
set(hw_grpc_srcs "${CMAKE_CURRENT_SOURCE_DIR}/generated/erzeuger.grpc.pb.cc")
set(hw_grpc_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/generated/erzeuger.grpc.pb.h")
add_custom_command(
        OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
        COMMAND ${_PROTOBUF_PROTOC}
        ARGS --grpc_out "${CMAKE_CURRENT_SOURCE_DIR}/generated"
        --cpp_out "${CMAKE_CURRENT_SOURCE_DIR}/generated"
        -I "${hw_proto_path}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${hw_proto}"
        DEPENDS "${hw_proto}")

# Include generated *.pb.h files
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/generated")

# hw_grpc_proto
add_library(hw_grpc_proto
        ${hw_grpc_srcs}
        ${hw_grpc_hdrs}
        ${hw_proto_srcs}
        ${hw_proto_hdrs})
target_link_libraries(hw_grpc_proto
        ${_REFLECTION}
        ${_GRPC_GRPCPP}
        ${_PROTOBUF_LIBPROTOBUF})

target_link_libraries(Erzeuger
        hw_grpc_proto
        ${_REFLECTION}
        ${_GRPC_GRPCPP}
        ${_PROTOBUF_LIBPROTOBUF})