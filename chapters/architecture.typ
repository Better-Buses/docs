= Architecture

To realize this project, we selected a three-tier Fog Computing architecture. This hybrid approach balances local processing with heavy cloud analytics to ensure low latency, efficient bandwidth usage, and high scalability. The main task of the sensors is just to collect all the relevant data and then send them to a local and centralized server that does all the computing and calculations. After that, the data is sent to the cloud, which comprehends all the data and provides a monitoring interface with graphs in order to make all information humanly readable.

#figure(image("../assets/png/arch.png", width: 50%), caption: [System architecture])


== Layers <sec-layers>

=== Edge Layer

The primary role of the bus-mounted sensors is localized data ingestion. They act as lightweight edge devices responsible for continuously collecting raw transit data (such as GPS coordinates, time stamps, and speed variations) without overloading local processing capacity. Instead those mounted in the stops serves like a checkpoint station in order to track automatically at which stop and what time a bus arrived.

=== Fog Layer

Once collected, these raw data packages are transmitted to localized fog nodes and regional servers. This layer performs the initial data filtering, aggregation, and critical real-time calculations, such as computing immediate route delays. By handling processing at the fog level, we minimize data transmission costs and enable rapid localized response times.

=== Cloud Layer

Finally, the pre-processed data is forwarded to a centralized cloud platform. The cloud orchestrates large-scale data aggregation, historical analysis, and can run predictive machine learning models. Crucially, the cloud layer hosts a comprehensive monitoring interface, converting complex datasets into human-readable dashboards, real-time graphs, and predictive analytics for stakeholders and urban planners.

== Technology Stack

Speaking of the implementation we decided to mainly stick with those discovered and studied during the lectures.

=== OpenNebula

OpenNebula serves as the core cloud hypervisor and cloud management platform, orchestrating the creation, deployment, and management of our virtualized infrastructure. Given the scale of the physical deployment, OpenNebula allows us to build a high-fidelity simulation environment by provisioning distinct Virtual Machines to emulate each physical component of our architecture. This virtualized ecosystem is divided into three node configurations, created in the following order:

- *Master VM* - the machine that hosts K3s in server mode and the primary services, with IP `172.16.100.2`.

- *Sensors VM* - a lightweight machine used only for simulation purposes, generating fake data from sensors divided into two areas. The assigned IP is `172.16.100.3`.

- *Worker-$Z$* - the machine that hosts the K3s in client mode, namely the worker in charge of elaborating data from the sensors in the zone $Z$. In our project we define two areas, hence two workers. However, since the amount of workers may vary, their IP is, generally speaking, `172.16.100.x` where #box[$x = 3 + Z$].


=== Kubernetes

To manage our data-processing applications within the fog layer, we deploy a Kubernetes cluster directly on top of the virtualized infrastructure provisioned by OpenNebula. This container orchestration strategy separates the infrastructure into a centralized Control Plane and a resilient Worker Layer. A single, dedicated OpenNebula virtual machine is allocated to act exclusively as the Kubernetes Control Plane (master node). This node serves as the brain of the cluster, executing core components such as scheduler and controller manager. The other VMs are configured as Kubernetes worker nodes. These nodes will host the application workloads encapsulated within pods. These worker pods execute the microservices responsible for real-time data processing and filtering. By leveraging Kubernetes on top of our fog nodes, the system inherits robust self-healing mechanisms to ensure uninterrupted data streams and guarantees pod replication and workload rescheduling.

=== Prometheus and Grafana

To bridge the gap between complex data streams and actionable insights, we deploy the Prometheus and Grafana monitoring stack within our centralized cloud layer. Prometheus serves as the core time-series database and monitoring toolkit, actively scraping and storing metrics related to both infrastructure health (e.g. node status, resource consumption) and application-level sensor data. Grafana acts as our universal data visualization hub, directly querying Prometheus to aggregate these disparate metrics and present them through an intuitive, real-time, and human-readable web interface.

=== Security

For the security aspect we decided to adopt two main level of security.

==== Container Hardening

To minimize the attack surface of our data-processing microservices, we apply strict container hardening techniques. This ensures that each container is as resilient as possible against exploitation:

- *Privilege escalation prevention* - containers are configured to run as non-root users, stripping away unnecessary administrative capabilities.

- *Minimal image footprint* - we utilize lightweight base images to remove unnecessary binaries, libraries, and functionalities that could be leveraged by an attacker.

==== Kubernetes Network Policies

By implementing Network Policies, we enforce a "Zero Trust"-like posture between services:

- *Namespace isolation* - distinct environments are isolated into dedicated namespaces.

- *Granular traffic control* - we define explicit "allow-lists" for pod-to-pod communication (Ingress/Egress lists). This ensures that a compromised sensor-data pod cannot laterally communicate with the visualization database or the control plane unless explicitly authorized.

==== OpenNebula Security Groups and Virtual Firewalls

Another layer of defense is managed at the hypervisor level through OpenNebula security groups, specifically designed per each type of VM. *Master-SG* and *Worker-SG* are created and assigned to the Master VM and Worker VMs respectivelly, each one allowing inbound traffic from specific IP addresses through specific ports according to their role in the cluster. The default security group is left to the Sensors VM since it is used for simulation only.

==== Falco and Falcosideckick

Falco operates as an advanced behavioral activity monitor designed to detect anomalous activity. In out case it continuously observes for:

- *Remote shell opening* - detecting if a terminal is unexpectedly spawned inside a running pod, specifically the one in charge of running MQTT.

- *Accessing sensitive host files* - monitoring if a container attempts to read host-level files outside its authorized scope (e.g. `/etc/passwd`), suggesting an attacker is trying to perform privilege escalation or gather critical system information.

- *Establishing unexpected outbound connections* - ensuring that pods strictly adhere to their intended communication paths.

To enhance incident response and alert management, Falcosidekick is deployed alongside Falco to seamlessly process, aggregate, and forward these real-time security alerts to our centralized monitoring channels.

==== Reverse Proxy
Nginx is deployed as a reverse proxy to secure external access to the Prometheus monitoring interface, as Prometheus lacks built-in authentication mechanisms by default.

== Labels and namespaces

To optimize sensor management and enforce strict scheduling rules within our Kubernetes cluster, we implement node selector policies by assigning targeted labels to our nodes. We defined two primary labels based on the workloads' operational responsibilities:

- *Workers* - label assigned to nodes handling traffic data analysis. These workloads track where buses experience delays or prolonged stops, correlating the data with specific times and days to calculate traffic averages.

- *Zone-$Z$* - namespace assigned to nodes responsible for monitoring data that comes from a specific zone $Z$ in the city (e.g zone-1). This includes both types of sensors.

- *Falco* - namespace assigned to pods that run an instance of Falco and Falcosideckick in order to check and trigger alerts.
