---
layout: post
status: publish
published: true
title: Disk Debugging
date: !binary |-
  MjAxNC0wNy0wOCAxMjowNTowMSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNy0wOCAwMjowNTowMSAtMDQwMA==
---
<a href="https://dodwell.us/linux-cpu/" title="Linux CPU">sar</a> gives us an overview of what the system is doing. If you had a high %iowait you might want to figure out what drive is currently being used. To do this we use 'iostat'. 'iostat' will by default give you all the reads and writes that the server has performed since start up.

{% highlight bash %}
root@earth:~# iostat
Linux 3.11.0-15-generic (earth)        07/01/2014      _x86_64_        (8 CPU)
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           4.71    0.08    1.76    2.70    0.00   90.75
Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              43.18       444.49       377.38 4868027082 4133006543
sdb              43.21       390.18       437.79 4273169451 4794601370
sdc              43.37       372.14       455.47 4075619576 4988231906
sdd              43.12       303.40       520.57 3322820691 5701198578
md0             112.68       196.71       987.63 2154354407 10816361389
dm-0              0.02         0.00         0.02       3710     191813
dm-1              0.07         0.13         0.15    1415036    1608712
dm-2            105.45       196.58       987.46 2152916405 10814560864
root@earth:~#
{% endhighlight %}

You can specify the following command to tell you where data is currently being written to disk.

{% highlight bash %}
root@earth:~# iostat 5 2
Linux 3.11.0-15-generic (earth)        07/01/2014      _x86_64_        (8 CPU)
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           4.71    0.08    1.75   32.70    0.00   70.75
Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              43.19       444.48       377.40 4870534754 4135461454
sdb              43.22       390.15       437.81 4275250131 4797504917
sdc              43.37       372.11       455.50 4077567336 4991286137
sdd              43.12       303.37       520.60 3324288487 5704684509
md0             112.70       196.63       987.67 2154614063 10822740329
dm-0              0.02         0.00         0.02       3710     191813
dm-1              0.07         0.13         0.15    1415124    1608712
dm-2            105.46       196.50       987.50 2153175973 10820939804
dm-3            123.51       420.50      9537.33 93284825825 394839274299
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          13.69    0.00    0.35   22.20    0.00   63.76
Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              27.40         3.20       283.40         16       1417
sdb              23.40         7.20       227.40         36       1137
sdc              17.40       158.40        57.80        792        289
sdd              14.20       165.60         1.80        828          9
md0              77.80         3.20       281.60         16       1408
dm-0              0.00         0.00         0.00          0          0
dm-1              0.00         0.00         0.00          0          0
dm-2             70.60         3.20       281.60         16       1408
dm-3           1392.60      1209.40      9012.49       4931       5912
root@earth:~#
{% endhighlight %}

It should be noted that the first block of text is indeed the total summary since startup. The second block is an average from the last 5 seconds.

On a heavily used system, sometimes, it's not that apparent what process is causing a high amount of load to a certain drive. Once we have identified what drive is under load with iostat we can find the drives mount point (dmsetup ls) and then use a program called 'lsof' to find what processes have files open on that mount.

{% highlight bash %}
root@earth:~# dmsetup ls
vg_earth-boot  (252:0)
vg_earth-swap  (252:1)
vg_earth-root  (252:2)
vg_earth-usr   (252:2)
root@earth:~# mount | grep vg_earth-usr
/dev/mapper/vg_earth-app on /app type ext4 (rw,errors=remount-ro)
root@earth:~# lsof +D /usr/
COMMAND     PID     USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
irqbalanc  1421     root  txt    REG  252,2    44136 13896668 /usr/sbin/irqbalance
sshd       8424     root  mem    REG  252,2    14536 13894192 /usr/lib/x86_64-linux-gnu/libck-connector.so.0.0.0
sshd       8518   dodwmd  mem    REG  252,2    14536 13894192 /usr/lib/x86_64-linux-gnu/libck-connector.so.0.0.0
php-cgi    9346 www-data  cwd    DIR  252,2    49152 13893777 /usr/bin
php-cgi    9346 www-data  txt    REG  252,2  9022832 13894634 /usr/bin/php5-cgi
php-cgi    9346 www-data  mem    REG  252,2   162032  4333607 /usr/lib/php5/20121212/xcache.so
php-cgi    9346 www-data  mem    REG  252,2   179184 13894891 /usr/lib/x86_64-linux-gnu/libedit.so.2.0.47
php-cgi    9346 www-data  mem    REG  252,2    31472  4332415 /usr/lib/php5/20121212/readline.so
...
...
{% endhighlight %}


### iotop

If we still don't know what file(s) are being written to the most, you can use a program called 'iotop' to figure out what files on a certain mount are being written to more than anything else.

{% highlight bash %}
root@earth:/# iotop -o -a -P -b -d 5 -n 5 `lsof +D /usr -t | sed 's/^/-p /g'`
Total DISK READ :       0.00 B/s | Total DISK WRITE :       0.00 B/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:       0.00 B/s
  PID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
Total DISK READ :       0.00 B/s | Total DISK WRITE :      27.94 K/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:     107.77 K/s
  PID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
20396 be/4 www-data      0.00 B     24.00 K  0.00 %  2.24 % php-cgi
32108 be/4 www-data      0.00 B      4.00 K  0.00 %  0.00 % php-cgi
Total DISK READ :      59.67 K/s | Total DISK WRITE :       3.98 K/s
Actual DISK READ:      59.67 K/s | Actual DISK WRITE:       3.98 K/s
  PID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
20396 be/4 www-data      0.00 B     24.00 K  0.00 %  1.12 % php-cgi
32108 be/4 www-data      0.00 B      4.00 K  0.00 %  0.00 % php-cgi
Total DISK READ :       0.00 B/s | Total DISK WRITE :       0.00 B/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:       0.00 B/s
  PID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
20396 be/4 www-data      0.00 B     24.00 K  0.00 %  0.75 % php-cgi
32108 be/4 www-data      0.00 B      4.00 K  0.00 %  0.00 % php-cgi
Total DISK READ :       0.00 B/s | Total DISK WRITE :       3.98 K/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:     286.66 K/s
  PID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
20396 be/4 www-data      0.00 B     24.00 K  0.00 %  0.56 % php-cgi
32108 be/4 www-data      0.00 B      4.00 K  0.00 %  0.00 % php-cgi
root@earth:/#
{% endhighlight %}
 
In the above command we ask iotop: (-o) Only show processes or threads actually doing I/O, (-a) Show accumulated I/O instead of bandwidth, (-P) only show processes - not threads, (-b) turn on non-interactive mode, (-d 5) set the delay between iterations in seconds, (-n 5) set the number of iterations before quitting. Then we call lsof +D /usr -t to output only the PID's that are currently using /usr and use sed to put -p in front of the PID so that it can be called with iotop. In the output you now have a list of PID's that are currently using disk I/O on the drive in question.  

Using some really great tools we're able to figure out exactly what is causing heavy load of a file system so that we can deliver a better experience to users while ensuring we don't over deliver and increase the costs of hosting.
