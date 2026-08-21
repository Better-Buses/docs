= Implementation
To validate our architectural design, we constructed a fully functional simulation environment focused on dynamic scaling, localized edge processing, and operational resilience.

== Infrastructure Setup
To simulate a distributed fog network on a local machine, we utilized a nested virtualization strategy. A primary Ubuntu Server 24.04 VM (via VirtualBox) acts as the central controller, with hardware nested virtualization enabled to allow OpenNebula to utilize KVM internally.  \
To ensure reproducibility, the deployment avoids manual configuration in favor of a highly automated, modular Git-based architecture. The repository is divided into four isolated branches, each bootstrapping a specific component via OpenNebula's contextualization scripts (`start-script.sh`):

- *Host* - manages the foundational IaaS layer. It automates the provisioning of OS images, VM templates, OpenNebula Security Groups, and the VMs themselves. It also configures port forwarding (30000 for Grafana, 30001 for Prometheus) to expose the centralized monitoring dashboards outside the virtualized network.

- *Master-node* (Cloud Layer) - establishes the Kubernetes control plane by installing K3s in server mode. It automatically deploys the core infrastructure stack: Prometheus, Grafana, Nginx, and Falco. Once the cluster is active, a dedicated orchestration script deploys Mosquitto brokers, Telegraf pods, and network policies, utilizing Kubernetes node labels to assign these workloads specifically to the edge nodes.

- *Worker-node* (Fog Layer) - dynamically provisioned by OpenNebula as edge processors, these VMs automatically configure K3s in client mode to seamlessly join the Kubernetes cluster.

- *Sensors* - dedicated VM running Python simulators to replicate urban telemetry. It models two distinct areas (each with one bus and five stops), injecting stochastic delays upon arrival at bus stops to accurately mimic real-world traffic fluctuations and passenger boarding friction.
