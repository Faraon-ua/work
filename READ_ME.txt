Steps to install and configure Postgres-xc

1) Postgres-xc Installation.
Run install_postgres-xc.sh on every server which you want to connect to Postgres-xc cluster.

2) Configuring and running Global Transaction Manager (GTM).
GTM provides global transaction management feature to all the other components in Postgres-XC database cluster. Because GTM handles transaction requirements from all the coordinators and datanodes, it is highly advised to run this in a separate server (NO DATANODES and COORDINATORS should reside on that server).
To configure and launch GTM run setup_and_run_gtm.sh

3) Configuring and running GTM Proxy.
Gtm proxy provides proxy feature from Postgres-XC coordinator and datanode to gtm. Gtm proxy groups connections and interactions between gtm and other Postgres-XC components to reduce both the number of interactions and the size of messages. 

To configure and launch GTM proxy run setup_and_run_gtm_proxy.sh on each server (node) where you are going to reside Datanode and Coordinator

4) Configuring and running Datanode.
Datanode actually stores your data. Tables may be distributed among datanodes, or replicated to all the datanodes. Because datanode does not have global view of the whole database, it just takes care of locally stored data. Incoming statement is examined by the coordinator as described next, and rebuilt to execute at each datanode involved. It is then transferred to each datanodes involved together with GXID and Global Snapshot as needed. Datanode may receive request from various coordinators. However, because each the transaction is identified uniquely and associated with consistent (global) snapshot, data node doesn't have to worry what coordinator each transaction or statement came from. 
Datanode is almost native PostgreSQL with some extension.
To configure and launch Datanode setup_and_run_datanode.sh on each server(node).

5) Configuring and running Coordinator.
Coordinator is an interface to applications. It acts like conventional PostgreSQL backend process. However, because tables may be replicated or distributed, coordinator does not store any actual data. Actual data is stored by datanode as described below. Coordinator receives SQL statements, get Global Transaction Id and Global Snapshot as needed, determine which datanode is involved and ask them to execute (a part of) statement. When issuing statement to datanodes, it is associated with GXID and Global Snapshot so that datanode is not confused if it receives another statement from another transaction originated by another coordinator. 
To configure and launch Coordinator setup_and_run_coordinator.sh on each server(node).

Before beginning your work

Please note that until now, we told each component where GTM is. However, coordinators do not know where other coordinators are and where datanodes are. They're very important configuration and you should configure them here.

Only coordinators need to know other nodes. Here, we use psql for this purpose and use CREATE NODE and ALTER NODE statement. At this moment, database called 'postgres' is available. So login to postgres. Because you created the database as user name postgresxc, you're the superuser.

First, you configure coord1.

[main]$ psql -p 20004 -h node01 postgres
# CREATE NODE coord2 WITH (TYPE = 'coordinator', HOST = 'nubuntu2.cloudapp.net', PORT = 2004);
# CREATE NODE datanode1 WITH (TYPE = 'datanode', HOST = 'nubuntu1.cloudapp.net', PORT = 2006);
# CREATE NODE datanode2 WITH (TYPE = 'datanode', HOST = 'nubuntu2.cloudapp.net', PORT = 2006);
# SELECT pgxc_pool_reload();
# \q
[main]$


Next, do the similar for coord2.

[main]$ psql -p 20004 -h node02 postgres
# CREATE NODE coord1 WITH (TYPE = 'coordinator', HOST = 'nubuntu1.cloudapp.net', PORT = 2004);
# CREATE NODE datanode1 WITH (TYPE = 'datanode', HOST = 'nubuntu1.cloudapp.net', PORT = 2006);
# CREATE NODE datanode2 WITH (TYPE = 'datanode', HOST = 'nubuntu2.cloudapp.net', PORT = 2006);
# SELECT pgxc_pool_reload();
# \q
[main]$

You must do the above only at the first time you started Postgres-XC cluster for each Coordinator in your cluster. After then, you skip this process and connect your applic
