---
layout: post
status: publish
published: true
title: Passing variables from shell scripts to GNU Make
date: !binary |-
  MjAxNC0wNS0wOSAwNDowNDowNyAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0wOSAwNDowNDowNyAtMDQwMA==
---
Make is a really useful tool when you want to be able to write simple jobs. You don't just need to use it for compiling source code. One thing you may wish to do is be able to pass variables to make commands. Lets take a look at a pretty simple Makefile that will delete all the indexes in Elastic Search.

{% highlight bash %}
endpoint := localhost:9200
all:
        curl -XDELETE ${endpoint}/_all
{% endhighlight %}
 
Running 'make' will spawn curl and delete the localhost:9200/_all

If we want to override the variable $endpoint with say 'es.remote.dodwell.us:9200' we can do that with the following:

{% highlight bash %}
dodwmd@earth:~/Makefiles$ make endpoint="es.remote.dodwell.us:9200"
{% endhighlight %} 
