+++
date = '2025-05-12T12:55:42+05:30'
draft = false
title = 'GeoDNS Load Balancing'
summary = 'How Load Balancing with GeoDNS works to ensure speedy delivery.'
+++

![](./lb.png)

## Contents

## Introduction

**Load balancing** is a technique to distribute workload incoming to a server across multiple servers. This is done typically for some reasons:

- To ensure no single server is overloaded
- To assure reliablility and availability of the service even when one server goes down

There are many types of load balancing algorithms. Some can be static or dynamic.

Static load balancers usually have a *master* server server that the request is hit and then it forwards the request to other servers.

Some examples of static load balancing algorithms are:
- Round Robin: Distributes requests evenly across all servers in a round robin fashion.
- Least connections: Directs traffic to the server with the least number of active connections.
- IP Hashing: Hashes the client's IP and redirects traffic to a specific server based on the hash value.

Dynamic load balancers are more complex and can redirect traffic based on the current load of the servers. There needs to be some montoring and chit-chat among the servers and the master to ensure that the load is distributed evenly.

## GeoDNS Load Balancing

So normally when I ping Google, I get a response somewhere close to me, like Chennai or Mumbai. In this particular instance, I got a response from Chennai it seems like. Here's the IP address I got:

```
142.250.206.14
```

![](./DNS-Chennai.png "Ping Response normally resolves to 142.250.206.14")

You can see the IP address is from Chennai, India. I used [Shodan.io](https://www.shodan.io/) to check the IP address. Here are the details about the [Chennai Google Server](https://www.shodan.io/host/142.250.206.14) on Shodan.

When I used a VPN to set my location to Tokyo, I got a different IP address. The IP address I got was:


```
142.250.199.110
```

![](./DNS-Tokyo.png "Ping Response with VPN set to Tokyo resolves to 142.250.199.110")

This is an IP address in Tokyo, again as per [Shodan](https://www.shodan.io/host/142.250.199.110)

## How does this work?

Same website, different IP address. In particular, closer to where my IP is actually located. This is because of GeoDNS load balancing.

Some websites with a lot of traffic from all across the world, cannot afford latency to have a single nameserver. They have multiple nameservers across the world. The IP of the request is checked and the nameserver closest to the IP is returned. This reduces latency significantly. Of course Google as in the above example, has a lot of servers across the world and want to ensure that the request is routed to the closest server.

---

## Further Reading and References

- [Cloudflare's Article on DNS Load Balancing](https://www.cloudflare.com/learning/performance/what-is-dns-load-balancing/)
- [ClouDNS GeoDNS Article](https://www.cloudns.net/blog/what-is-geodns-and-how-does-it-work/)
- [Shodan](https://www.shodan.io/)
