Project for the Module Distributed Systems

I tried to implement a little distributed energy system  that can simulate failure and recovery.
(There is a button for it. If you do not see this button please try to make build only a Zentrale via edit of the makefile.
This bug has happened to me via testing a few times)

Project Structure
The project consists of the following subprojects:

    Central Unit: The Central Unit takes over the communication between the components. It manages all components that have registered with it and provides a web server to access this data.
    Producer: The Producer ensures that data is continuously sent to the respective central unit. This data is calculated and should represent as accurate a simulation as possible.
    Consumer: The Consumer ensures that data is continuously sent to the respective central unit. This data is calculated and should represent as accurate a simulation as possible.
    Energy Supplier: With the Energy Supplier as an external client, one can request the data of the components and the values of all components via RPC.
    Load Balancer: The Load Balancer distributes incoming traffic across the central units.

Starting the Project
To start the project, Docker, Docker-Compose, and Git are required on the target machine. All commands must be executed by a user who is allowed to use Docker.

    Navigate to the main directory of the code base.
    Execute the command make build.
    (This will take some time)
    Start Docker containers with Compose:
        To start in the foreground: execute docker-compose up.
        To start in the background: execute docker-compose up -d.
    To start the Energy Supplier: execute docker-compose run energieversorger1 (best done with other things in the background).
    To simulate a failure of a central unit: docker-compose stop zentrale1, then docker-compose start zentrale1 (started in the background).

To Terminate the Services

    In the foreground: Press Ctrl + C on the keyboard.
    In the background: Execute docker-compose down.

Accessing the Project
Access to the web pages can be done via the individual central units:

    Central Unit 1: http://172.16.1.1:9000
    Central Unit 2: http://172.16.1.2:9000
    Central Unit 3: http://172.16.1.3:9000

Or via the Load Balancer:

    Load Balancer: http://172.16.0.3:10000

The most important implementation is in the Zentrale/ folder. Therefore, I included another readme.txt there.