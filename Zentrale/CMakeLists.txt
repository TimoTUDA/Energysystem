cmake_minimum_required(VERSION 3.8)
project(Zentrale)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package (Threads REQUIRED)

# main target
add_executable(Zentrale src/cpp/main.cpp src/header/Rpc/ZentralenSyncRpcServer.h src/cpp/Rpc/ZentralenSyncRpcServer.cpp src/cpp/Zentrale.cpp src/header/Zentrale.h src/cpp/WebServer/Webserver.cpp src/header/WebServer/Webserver.h src/cpp/Komponenten/Komponente.cpp src/header/Komponenten/Komponente.h src/cpp/Komponenten/Erzeuger.cpp src/header/Komponenten/Erzeuger.h src/cpp/Komponenten/Verbraucher.cpp src/header/Komponenten/Verbraucher.h src/cpp/UDPServer/UDPServer.cpp src/header/UDPServer/UDPServer.h src/header/UDPServer/UDPCallback.h src/cpp/WebServer/HTTPIntepreter.cpp src/header/WebServer/HTTPIntepreter.h src/cpp/Komponenten/KomponentenController.cpp src/header/Komponenten/KomponentenController.h src/cpp/WebServer/HttpContextHandlerController.cpp src/header/WebServer/HttpContextHandlerController.h src/header/WebServer/HttpContextHandler.h  src/cpp/WebServer/HTMLGenerator.cpp src/header/WebServer/HTMLGenerator.h src/cpp/UDPSender/UDPSender.cpp src/header/UDPSender/UDPSender.h src/cpp/UDPSender/KomponentenUdpSender.cpp src/header/UDPSender/KomponentenUdpSender.h src/cpp/Rpc/RpcServer.cpp src/header/Rpc/RpcServer.h src/cpp/Rpc/ErzeugerRpcClient.cpp src/header/Rpc/ErzeugerRpcClient.h src/header/Rpc/MqttInterfaceZentrale.h)
target_link_libraries(Zentrale ${CMAKE_THREAD_LIBS_INIT})


#Mqtt stuff
find_package(PahoMqttCpp REQUIRED)
target_link_libraries(Zentrale paho-mqttpp3)
target_link_libraries(Zentrale paho-mqtt3a)
target_link_libraries(Zentrale paho-mqtt3c)


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



message("entering protofiles")
message(${CMAKE_CURRENT_SOURCE_DIR})
message("no")
# Proto file
file(GLOB protoFiles "src/proto/*.proto")
foreach(filename ${protoFiles})

    get_filename_component(hw_proto "${filename}" ABSOLUTE)
    get_filename_component(hw_proto_path "${hw_proto}" PATH)
    get_filename_component(hw_proto_filename "${filename}" NAME_WE)

    # Generated sources
    set(MY_USR_PATH "/home/vboxuser/IdeaProjects/Energysystem/Zentrale")
    message("usrpath")
    message("${MY_USR_PATH}")
    set(hw_proto_srcs "${CMAKE_CURRENT_SOURCE_DIR}/generated/${hw_proto_filename}.pb.cc")
    set(hw_proto_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/generated/${hw_proto_filename}.pb.h")
    set(hw_grpc_srcs "${CMAKE_CURRENT_SOURCE_DIR}/generated/${hw_proto_filename}.grpc.pb.cc")
    set(hw_grpc_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/generated/${hw_proto_filename}.grpc.pb.h")
    add_custom_command(
            OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
            COMMAND ${_PROTOBUF_PROTOC}
            ARGS --grpc_out "${CMAKE_CURRENT_SOURCE_DIR}/generated"
            --cpp_out "${CMAKE_CURRENT_SOURCE_DIR}/generated"
            -I "${hw_proto_path}"
            --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
            "${hw_proto}"
            DEPENDS "${hw_proto}")


    message("something was done hereeeee")
    # hw_grpc_proto
    add_library(proto_${hw_proto_filename}
            ${hw_grpc_srcs}
            ${hw_grpc_hdrs}
            ${hw_proto_srcs}
            ${hw_proto_hdrs})
    target_link_libraries(proto_${hw_proto_filename}
            ${_REFLECTION}
            ${_GRPC_GRPCPP}
            ${_PROTOBUF_LIBPROTOBUF})

    target_link_libraries(Zentrale
            proto_${hw_proto_filename}
            ${_REFLECTION}
            ${_GRPC_GRPCPP}
            ${_PROTOBUF_LIBPROTOBUF})
endforeach()

# Include generated *.pb.h files
#set(MY_USR_PATH "/home/vboxuser/IdeaProjects/Energysystem/Zentrale")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/generated")
#include_directories("${MY_USR_PATH}/generated")
