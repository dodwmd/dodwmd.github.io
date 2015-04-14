---
layout: post
status: publish
published: true
title: elastic search abuse on AWS
date: !binary |-
  MjAxNC0wNy0yOSAwOTo0NzozMiAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNy0yOCAyMzo0NzozMiAtMDQwMA==
---
<a href="https://dodwell.us/insecure-default-in-elasticsearch-enables-remote-code-execution/" title="Insecure default in Elasticsearch enables remote code execution" target="_blank">Previously</a> I highlighted the release of an exploit to elastic search that results in the ability to execute unauthorized code on a server running elasticsearch 1.1.x. It has just been reported that this same exploit is now being used to install DDOS (distributed denial of service) bots on vulnerable machines hosted within AWS. Elasticsearch instances should always be treated like a database and not be directly exposed to the internet. As a minimum you should be using plugins to nginx to get JSON functionality direct from the web server and have it act as a proxy to back end processes like elastic search. This will help you filter requests so only the requests you authorize are able to be executed.


## further reading

<a href="https://securelist.com/blog/virus-watch/65192/elasticsearch-vuln-abuse-on-amazon-cloud-and-more-for-ddos-and-profit/" target="_blank" title="elasticsearch Vuln Abuse on Amazon Cloud and More for DDoS and Profit">https://securelist.com/blog/virus-watch/65192/elasticsearch-vuln-abuse-on-amazon-cloud-and-more-for-ddos-and-profit/</a>
