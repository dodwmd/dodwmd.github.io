---
published: true
status: publish
title: insecure default in elasticsearch enables remote code execution
date: 2014-05-30
url: /2014/05/30/insecure-default-in-elasticsearch-enables-remote-code-execution/
tags:
  - security
---

> Elasticsearch has a flaw in its default configuration which makes it possible for any webpage to execute arbitrary code on visitors with Elasticsearch installed. If you&rsquo;re running Elasticsearch in development please read the instructions on how to secure your machine. Elasticsearch version 1.2 (which is unreleased as of writing) is not vulnerable to remote code execution, but still has some security concerns.


## further reading

<a href="http://bouk.co/blog/elasticsearch-rce/" target="_blank">http://bouk.co/blog/elasticsearch-rce/</a>