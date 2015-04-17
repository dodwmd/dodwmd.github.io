---
layout: post
title: "Free HTML Webhosting"
description: How to host your blog or website for free including SSL certificates.
headline: Free HTML Webhosting
modified: 2015-04-16                # Date
category: blog
tags: []
comments: false
mathjax:
---
I wanted to cover off how I currently host this blog for free using a number of services being offered by different companies.

### what do you need this days?

This website has a few moving parts:

* Blog software
* Webhosting
* SSL Certificates
* SSL Forwarding


The following post describes how I managed to get all of the above setup for free.

### Blog Software

I'm currently using [jekyll](http://jekyllrb.com/) to for my blogging software. This allows me to create a bunch of files and using some Ruby markup the files into a HTML blog. This means that when I need to add a new post all I have to do is add a single text file with human readable text in it and then using some markup convert it into HTML pages for your viewing.

The [jekyll docs](http://jekyllrb.com/docs/usage/) has some really good information on how to get started. I had a look at [octopress](http://octopress.org/) but preferred to stick with native jekyll. If your a little on the unsure side of things I'd suggest using octopress.

### Webhosting

[Github](http://github.com/) which I already used to host [code](https://github.com/dodwmd/) also allows for [Github Pages](https://pages.github.com/). This is a web hosting service that takes a special branch from your repository 'gh-pages' and hosts the site for you. You can also setup personal sites naming them in a certain way and the master branch is used to host the site. This method also allows you to setup a 'CNAME' file that can use used to host custom domains/hostnames. Take a look at [this documentation](https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/) for more information. Unfortunately Github Pages doesn't allow for SSL termination.

### SSL Certificates

[StartSSL](https://www.startssl.com/) offers free SSL certificate signing. The website is a little clunky and is prone to outages but if you persist you can get a SSL signed certificate from them.

### SSL Forwarding

Now that you have a SSL certificate you can simply go and signup for a free account over at [CloudFlare](https://www.cloudflare.com/). Upload your signed certificate and turn on 'Flexible SSL'. This means the traffic between cloudflare and github is unencrypted but means that the user (and google!) will be viewing the site via a SSL certificate. This will help you in ranking and enables a caching service so if github should have an issue you have some redundancy. Win, Win!
