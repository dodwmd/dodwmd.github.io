---
layout: post
title: "UFW, fail2ban and blocking portscans oh my!"
description: Using fail2ban and UFW together to block unwanted traffic
headline: How to get UFW and fail2ban to work together to block port scanning  # Will appear in bold letters on top of the post
modified: 2015-05-28                # Date
category: security
tags: []
comments: false
mathjax:
---
I just wanted to write down some issues I had as a reminder to myself and some notes that other people might find useful. I want to be able to setup some automatic host based firewall rules for some servers I look after so help mitigate any possible brute force attacks and general nastiness that you get on the internet. To do this I'm going to install UFW, fail2ban and setup some filters and actions in fail2ban to use information from UFW on Ubuntu 14.04.2.

### what is it? 

*fail2ban*

I've used [fail2ban](http://www.fail2ban.org/) as a minimal method to stop brute force attacks. Basically it will read config files for different services and if someone enters in the wrong password too many times will firewall them from the server for a period of time. This wont stop someone from 'eventually' brute forcing poor passwords but it increases the time taken exponentially and hopefully they get bored and move onto softer targets.

*UFW*

I've started using [UFW](https://help.ubuntu.com/community/UFW) a little while ago. Normally I prefer to use [shorewall](http://shorewall.net/) but it can be a little complex to setup at times so for this post I'm going to focus just on UFW.

### where to start

First you need to get UFW all installed and ready to go.

{% highlight bash %}
$ sudo apt-get -y install ufw fail2ban
$ sudo sed -i 's/IPV6=no/IPV6=yes/g' /etc/default/ufw
$ sudo ufw allow ssh
$ sudo ufw default deny incoming
$ sudo ufw default allow outgoing
$ sudo ufw logging low
$ sudo ufw disable
$ sudo ufw enable
{% endhighlight %}

The above should install UFW & fail2ban. In UFW it should enable IPv6 support, allow ssh and setup some default firewall direction rules. We also want to only log denined packets to the kernel logger. The last step gives it a restart (disable/enable).

Now if we generate some port open requests from another server to a port other than ssh we should see this:
{% highlight bash %}
$ sudo dmesg
[3071864.995451] [UFW BLOCK] IN=venet0 OUT= MAC= SRC=192.168.0.1 DST=192.168.0.2 LEN=48 TOS=0x00 PREC=0x00 TTL=46 ID=12308 PROTO=UDP SPT=40393 DPT=40104 LEN=28
{% endhighlight %}

Great! But you need this in a log file so fail2ban can use it. Lets take a look at our rsyslogd config:

{% highlight bash %}
root@vps:/etc/rsyslog.d# ls -la *ufw*
-rw-r--r--   1 root root    94 May 28 01:31 20-ufw.conf
root@vps:/etc/rsyslog.d# cat 20-ufw.conf
# Log kernel generated UFW log messages to file
:msg,contains,"[UFW " /var/log/ufw.log
root@vps:/etc/rsyslog.d#
{% endhighlight %}

Great UFW has already setup a method to log UFW messages. But when I checked /var/log/ufw.log it didn't exist. Restarting rsyslog didn't seem to help. But then I noticed /etc/rsyslogd.conf:


{% highlight bash %}
#  /etc/rsyslog.conf    Configuration file for rsyslog.
#
#                       For more information see
#                       /usr/share/doc/rsyslog-doc/html/rsyslog_conf.html
#
#  Default logging rules can be found in /etc/rsyslog.d/50-default.conf


#################
#### MODULES ####
#################

$ModLoad imuxsock # provides support for local system logging
#$ModLoad imklog   # provides kernel logging support
#$ModLoad immark  # provides --MARK-- message capability

{% endhighlight %}

After enabling '$ModLoad imklog' I get the following in /var/log/kern.log:

{% highlight bash %}
May 28 01:38:00 vps rsyslogd: imklog: cannot open kernel log (/proc/kmsg): Operation not permitted.
{% endhighlight %}

This appears due to rsyslog not opening /proc/kmsg before it drops it's privs! This is now where we get into hacky area. Some people suggest using dd to mirror /proc/kmsg and getting rsyslogd to open that. Personally I just stopped rsyslog from dropping it's privs all together.

Edit /etc/rsyslogd.conf and comment out the following:

{% highlight bash %}
$PrivDropToUser syslog
$PrivDropToGroup syslog
{% endhighlight %}

Now restart rsyslogd with 'service rsyslog restart'.

Checking /var/log/ufw.log it now exists and it has some data in it for us to play with! Great! Lets move onto fail2ban.

### fail2ban

fail2ban will insert iptables rules when it chooses to ban hosts. This can cause a problem with UFW so lets make fail2ban play nicely with UFW.

First lets setup a action rule that we can use to deny/allow users from being able to connect in:

{% highlight bash %}
echo '[Definition]
actionstart =
actionstop =
actioncheck =
actionban = ufw deny in from <ip>
actionunban = ufw delete deny in from <ip>' | sudo tee /etc/fail2ban/action.d/ufw.conf
{% endhighlight %}

While here you might want to edit your jail.conf file and update where required the actions of other services you want to monitor.

Now lets setup a filter for our log file to know when to ban a user:

{% highlight bash %}
echo '[Definition]
failregex = UFW BLOCK.* SRC=<HOST>
ignoreregex =' | sudo tee /etc/fail2ban/filter.d/portscan.conf
{% endhighlight %}

Now the clever amoung you will realise that UFW will block port ATTEMPTS which means that some nice fellow could craft some packets so that the connection attempt comes from hosts that should be allowed to connect.

Lets setup some whitelist rules to make sure our networks and hosts that should never be firewalled aren't. In jail.conf you will find a 'whitelist' varible. Lets update this with all our friendly networks.

{% highlight bash %}
whilelist = 10.0.0.0/8
{% endhighlight %}

Ok now we just need to add a rule to tie it all together in our jail.conf file:

{% highlight bash %}
echo '[portscan]
enabled  = true
filter   = portscan
logpath  = /var/log/ufw.log
action   = ufw
maxretry = 5
' | tee -a /etc/fail2ban/jail.conf
{% endhighlight %}

And lastly don't forget to reload fail2ban:

{% highlight bash %}
sudo service fail2ban restart
{% endhighlight %}
