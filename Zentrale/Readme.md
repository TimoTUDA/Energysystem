Using the Central Unit

The central unit is accessed through the browser via the address bar at http://localhost:9000/.
Here, an overview of all devices detected so far is available.
A detailed listing of all devices can be found by selecting a device in the table or via http://localhost:9000/Detail?name=<name>&history=true.
The port of the web server can be changed via a parameter at program start.

Devices can report their data over the UDP port 5000. Communication is transmitted as a parsed string in JSON format.
Synchronization and Distribution of Data

When a central unit starts, it requests data from other central units (passed as program parameters) via an RPC call.
Once the central unit is up and running and has data, it sends these to the requesting central unit via MQTT.

Throughout its operation, a central unit receives data only from its components.
This data is then also sent via MQTT to other known central units.
If a central unit fails, the data from components that only send to this central unit will not be available during this period.
Class Structure
Central Unit

The central unit initializes and starts all required components.
Both the web server and data communication are organized here.
All configurations of the process take place here.
Functions:

    Central(): The constructor of the class.
    Here, the central unit is initialized with all necessary information (ports for web and UDP servers).
    HTTP contexts for the web server are added here, so they are accessible as soon as the web server is started.
    start(): Starts the central unit and all its threads, where information processing and connection management occur.
    A web server is initialized and started in a thread (see WebServer).
    A UDP server is initialized and started in a thread (see UDPServer).
    The start() method will return only when the program is to be terminated.
    stop(): The stop() method sets the stop flag to true in all components of the central unit, thus ensuring that all threads are terminated.
    After it has been called, the program ends after the web server and UDP server have been stopped.

UDPServer and UDPCallback

The UDPServer class functions:

    init(int port): Initializes the class and creates a socket on the operating system.
    The given parameter is used as the port.
    The socket is opened as a Datagram socket on all IPv4 addresses, and a timeout of 1s is set for the server.
    The returned file descriptor is stored as an object attribute.
    setCallback(UDPCallback*): Sets the callback to be called when a message arrives.
    operator()(): This function makes the object a functor, so it can be started as a thread.
    It calls the run() method.
    stop(): The stop method sets a flag in the object indicating whether the socket should continue waiting for incoming data. The flag is the stop condition in the run() method.
    run(): Here, the main loop of the thread takes place.
    As long as the stop flag is not set, the socket reads data.
    A 1500-long buffer is provided into which data is read from the previously created socket.
    If bytes are received (no timeout/error detected), the object's callback method is called with the received data converted to a string.
    Upon exiting the loop, the thread's task is completed (server can be closed), and the socket is attempted to be closed.

The UDPCallback class serves as an interface for other classes to process a message. It is called when a message is received in the UDPServer's run() method.

    processMessageUdp(string): An overridable function that is called when a message is received.

RPCServer
Proto File

The Proto files are located in the src/proto folder and describe the RPC calls.

    erzeuger.proto describes the communication between the producer and the central unit.
    SetStatus() can be used to turn the respective producer on and off.
    rpcServer.proto describes the communication between the energy supplier and the central unit.
    Current data of producers/consumers can be requested.
    GetKomponentenIDs returns a list with only the IDs of all components.
    GetKomponente returns the detailed data of the components.
    GetKomponentenWerte returns the values/data of the respective component.

The Proto files are automatically placed in the generated folder during the build process and integrated.
RpcServer

The RpcServer class takes care of the connection/provision of the RPC service for the energy supplier.
It is started and managed in the Central class.
It inherits from the Component::Service class, which is created from the service in the Proto file.