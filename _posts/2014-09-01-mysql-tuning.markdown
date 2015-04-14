---
layout: post
status: publish
published: true
title: MySQL Tuning
date: !binary |-
  MjAxNC0wOS0wMSAxMTo0NTozMCAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wOS0wMSAwMTo0NTozMCAtMDQwMA==
---
Previously I wrote about <a href="https://dodwell.us/linux-memory/" title="Linux Memory">Linux Memory</a> and <a href="https://dodwell.us/linux-cpu/" title="Linux CPU">Linux CPU</a>. This post I want to talk about database tuning, mainly in regards to MySQL.


### mysql table types

Before we can begin to allocate the correct amount of RAM to MySQL we need to have a good understanding of the type of data we're serving and the type of load the data is going to receive. MySQL has two main table types, MyISAM and InnoDB.


### myisam

MyISAM was the default storage engine for the MySQL relational database management system versions prior to 5.5. It is based on the older ISAM code but has many useful extensions. 

MyISAM is optimized for environments with heavy read operations, and few writes, or none at all. A typical area in which one could prefer MyISAM is data warehouse, because it involves queries on very big tables, and the update of such tables is done when the database is not in use (usually by night).


### innodb

InnoDB is a general-purpose storage engine that balances high reliability and high performance. As of MySQL 5.5, it is the default MySQL storage engine. In MySQL 5.6, issuing the CREATE TABLE statement without an ENGINE= clause creates an InnoDB table.

InnoDB uses row level locking to enable fast updates to table information and is generally best suited for storage of data with a high frequency of change.


#### separate workloads

Generally speaking a MySQL server should serve either MyISAM or InnoDB table types. If you have different use cases (need to warehouse data and have a web frontend you wish to service) it's generally good practise to have separate database clusters setup to service each of these use cases. Although you can mix table type types on your MySQL server, you won't be able be able to gain the maximum performance for your server/cluster.

When dealing with databases it's always a good idea to be using a 64-bit address space. This means we have access to more than 4G of memory without having to use OS tricks (Physical Address Extension) that generally have performance hits.


#### innodb buffer pools

If using just InnoDB, set innodb_buffer_pool_size to 70% of _available_ RAM. (Plus key_buffer_size = 10M, small, but not zero.) If you have lots of RAM and are using 5.5 (or later), then consider having multiple pools. Recommend 1-16 innodb_buffer_pool_instances, such that each one is no smaller than 1GB. (Sorry, no metric on how much this will help; probably not a lot.) 

Meanwhile, set key_buffer_size = 20M (tiny, but non-zero) 

InnoDB does all its caching in a the "buffer pool", whose size is controlled by innodb_buffer_pool_size. It contains 16KB data and index blocks from the open tables, plus some maintenance overhead. 

MySQL 5.5 (and 5.1 with the "Plugin") lets you declare the block size to be 8KB or 4KB. MySQL 5.5 allows multiple buffer pools; this can help because there is one mutex per pool, thereby relieving some of the Mutex bottleneck.

If you are sharing resources on a MySQL server and want to estimate what the correct allocation of RAM should be (rather than just taking 70% of the RAM). You can estimate this via looking at the databases hosted on the server. Add up Data_length + Index_length for all the InnoDB tables. Set innodb_buffer_pool_size to no more than 110% of that total. Make sure this number is less than the 70% of available RAM, otherwise it could lead to the system swapping.

You can run the following SQL to get the sizes of the data used by your engines:

{% highlight bash %}
SELECT  ENGINE,
    ROUND(SUM(data_length) /1024/1024, 1) AS "Data MB",
    ROUND(SUM(index_length)/1024/1024, 1) AS "Index MB",
    ROUND(SUM(data_length + index_length)/1024/1024, 1) AS "Total MB",
    COUNT(*) "Num Tables"
FROM  INFORMATION_SCHEMA.TABLES
WHERE  table_schema not in ("information_schema", "performance_schema")
GROUP BY  ENGINE;
{% endhighlight %}
 
#### myisam key_buffers

If using just MyISAM, set key_buffer_size to 20% of <em>available</em> RAM. (Plus innodb_buffer_pool_size=0) 

MyISAM does two different things for caching. 


* Index blocks (1KB each, BTree structured, from .MYI file) live in the "key buffer".
* Data block caching (from .MYD file) is left to the OS, so be sure to leave a bunch of free space for this.

To check the health of your key_buffers run the following: 

{% highlight bash %}
SHOW GLOBAL STATUS LIKE 'Key%';
{% endhighlight %}
 
Now, calculate Key_read_requests / Key_reads If it is high (say, over 10), then the key_buffer is big enough. You can also add up Index_length for all the MyISAM tables. Set key_buffer_size no larger than that size. Use the SQL in the InnoDB section above to select the index_length for your MyISAM tables.


#### mutex bottleneck

MySQL was designed in the days of single-CPU machines, and designed to be easily ported to many different architectures. Unfortunately, that lead to some sloppiness in how to interlock actions. There are small number (too small) of "mutexes" to gain access to several critical processes. Of note: 

* MyISAM's key_buffer
* The Query Cache
* InnoDB's buffer_pool

With multi-core boxes, the mutex problem is causing performance problems. In general, past 4-8 cores, MySQL gets slower, not faster. MySQL 5.5 and Percona's XtraDB are making that somewhat better in InnoDB; the practical limit for cores is more like 32, and performance tends plateaus after that rather than declining. 5.6 claims to scale up to about 48 cores. 


#### hyperthreading and multiple cores

HyperThreading is great for marketing, lousy for performance. It involves having two processing units sharing a single hardware cache. If both units are doing the same thing, the cache will be reasonably useful. If the units are doing different things, they will be clobbering each other's cache entries. 

Furthermore MySQL is not great on using multiple cores. So, if you turn off HT, the remaining cores run a little faster. 


#### open files

The OS has some limit on the number of open files it will let a process have. Each table needs 1 to 3 open files. Each PARTITION is effectively a table. Most operations on a partitioned table open <em>all</em> partitions. 

In *nix, ulimit tells you what the file limit is. The maximum value is in the tens of thousands, but sometimes it is set to only 1024. This limits you to about 300 tables. 

You can see how well your system is performing via SHOW GLOBAL STATUS; and computing the opens/second via Opened_files / Uptime If this is more than, say, 5, table_cache should be increased. If it is less than, say, 1, you might get improvement by decreasing table_cache. 


#### query cache

Generally speaking switching query_cache off should get rid of some unwanted overheads.

To turn off query_cache you can set the following in your mysql.conf file.

{% highlight bash %}
query_cache_type = OFF
query_cache_size = 0
{% endhighlight %}
 
To see how well your QC is performing, SHOW GLOBAL STATUS LIKE 'Qc%'; then compute the read hit rate: Qcache_hits / Qcache_inserts If it is over, say, 5, the QC might be worth keeping. 
If you decide the QC is right for you, then I recommend 

* query_cache_size = no more than 50M
* query_cache_type = DEMAND
* SQL_CACHE or SQL_NO_CACHE in all SELECTs, based on which queries are likely to benefit from caching.


#### thread_cache_size

This is a minor tunable. Zero will slow down thread (connection) creation. A small (say, 10), non-zero number is good. The setting has essentially no impact on RAM usage. 

It is the number of extra processes to hang onto. It does not restrict the number of threads; max_connections does. 


#### binary Logs

If you have turned on binary logging (via log_bin) for replication and/or point-in-time recovery, The system will create binary logs forever. That is, they can slowly fill up disk. Suggest setting expire_logs_days = 14 to keep only 14 days' worth of logs. It's also a good idea to store these logs on a separate mount point to your database files.


#### swappiness

MySQL would love for RAM allocations to be reasonably stable -- the caches are (mostly) pre-allocated; the threads, etc, are (mostly) of limited scope. <strong>ANY</strong> swapping is likely to severely hurt performance of MySQL. 

With a high value for swappiness, you lose some RAM because the OS is trying to keep a lot of space free for future allocations (that MySQL is not likely to need). 

With swappiness = 0, the OS will probably crash rather than swap. I would rather have MySQL limping than die. 

Somewhere in between, 5, is a good value for a MySQL-only server. 


#### tools

<a href="http://mysqltuner.com/" target="_blank">http://mysqltuner.com/</a>

MySQLTuner is a script written in Perl that allows you to review a MySQL installation quickly and make adjustments to increase performance and stability. The current configuration variables and status data is retrieved and presented in a brief format along with some basic performance suggestions.

<a href="https://launchpad.net/mysql-tuning-primer" target="_blank">https://launchpad.net/mysql-tuning-primer</a>

This script takes information from "SHOW STATUS LIKE..." and "SHOW VARIABLES LIKE..." then attempts to produce sane recommendations for tuning server variables. It is compatible with all versions of MySQL 3.23 and above.
