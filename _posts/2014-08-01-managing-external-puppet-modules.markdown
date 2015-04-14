---
layout: post
status: publish
published: true
title: managing external puppet modules
date: !binary |-
  MjAxNC0wOC0wMSAxNToyMjo1MSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wOC0wMSAwNToyMjo1MSAtMDQwMA==
---
I had a co-worker ask me about upgrading puppet modules and I thought I'd share the information I spoke to them about. Writing individual puppet modules for a client can be a time consuming process. Luckily for us puppet modules for common tasks have been written and published. Using these modules enables the Systems Administrator to cut down on the amount of code they need to write and manage. However, things get tricky when you're managing multiple environments (change controlled puppet deployments!), multiple networks/clients and want to keep the modules updated.

> Librarian-puppet is a bundler for your puppet infrastructure. You can use librarian-puppet to manage the puppet modules your infrastructure depends on, whether the modules come from the Puppet Forge, Git repositories or a just a path.
>
> * Librarian-puppet can reuse the dependencies listed in your Modulefile
> * Forge modules can be installed from Puppetlabs Forge or an internal Forge such as Pulp
> * Git modules can be installed from a branch, tag or specific commit, optionally using a path inside the repository
> * Modules can be installed from GitHub using tarballs, without needing Git installed
> * Module dependencies are resolved transitively without needing to list all the modules explicitly
> 
> Librarian-puppet manages your modules/ directory for you based on your Puppetfile. Your Puppetfile becomes the authoritative source for what modules you require and at what version, tag or branch.
> 
> Once using Librarian-puppet you should not modify the contents of your modules directory. The individual modules' repos should be updated, tagged with a new release and the version bumped in your Puppetfile.
> 
> It is based on Librarian, a framework for writing bundlers, which are tools that resolve, fetch, install, and isolate a project's dependencies.
> 
> -- <a href="http://librarian-puppet.com/" target="_blank">http://librarian-puppet.com/</a>


## further reading
<a href="http://librarian-puppet.com/" target="_blank">http://librarian-puppet.com/</a>
