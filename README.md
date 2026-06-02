# Foggy-sensors

> Cloud & Fog Computing project — University of Trento  
> IaaS: OpenNebula · PaaS: Kubernetes (K3s) · Security: Network Policy + Falco
> Authors : Soranzo Andrea,Precoma Andrea
> 
## Overview

Simulated environmental sensors (temperature, smoke) send data via MQTT to edge fog nodes. Each fog node preprocesses the data locally and forwards aggregates to a central cloud cluster. Chaos Mesh injects node failures to test system resilience: when a fog node goes down, Kubernetes reschedules its workloads automatically. Optionally, a Python script calls the OpenNebula API to reprovision the failed VM and rejoin it to the cluster.

```
[Sensor A]  [Sensor B]  [Sensor C]
     \           |           /
      \        MQTT         /
       \        |          /
   [Fog Node 1] [Fog Node 2] [Fog Node 3 💥]
    VM+K3s       VM+K3s       VM+K3s (chaos target)
          \         |         /
           \   aggregated    /
            \    data       /
             [K8s Master VM]
          [Prometheus + Grafana]
               [Security]
```

## Architecture

| Layer      | Technology                         | Role                              |
| ---------- | ---------------------------------- | --------------------------------- |
| IaaS       | OpenNebula                         | Provisions and manages all VMs    |
| Fog nodes  | K8s on OpenNebula VMs              | Local sensor data preprocessing   |
| Cloud      | Kubernetes master on OpenNebula VM | Cluster control plane, scheduling |
| Messaging  | MQTT (Mosquitto)                   | Sensor → fog node communication   |
| Monitoring | Prometheus + Grafana               | Metrics, dashboards               |

## Security Components

- **Network Policy** — namespaces isolated; only the aggregator pod may reach the cloud database
- **Hardened containers** — non-root user, read-only filesystem, `securityContext` in all manifests