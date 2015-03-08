# kafka-cluster

This is a simple wrapper cookbook to spin up a 3-node kafka + zookeeper cluster.
You can manage the zookeepers and browse the datastore using Exhibitor, which
runs on port 8080 on each node by default.

Usage
-------------
Currently this cookbook relies on DHCP addressing for the machines, so you'll
first have to `vagrant up`, then get the list of IP's, and then insert them at
the top of the default recipe before running `vagrant provision`.

I'm also using LXC, so you'll have to change the box if you want to user
another provider.
