---
layout: post
title: "Setting up Systemd to spawn ssh-agent and adding your keys"
description: In this post I will show how you can configure ssh-agent to spawn from systemd and add your keys upon login
headline: How to get ssh-agent to run from users systemd config
modified: 2016-12-18                # Date
category: security
tags: []
comments: false
mathjax:
---
I'm using bastion hosts for my cloud infra and found this little hack to systemd to setup ssh-agent for my auth forwarding.

### what is it? 

*systemd*

[systemd](https://en.wikipedia.org/wiki/Systemd) is an init system used in Linux distributions to bootstrap the user space and manage all processes subsequently, instead of the UNIX System V or Berkeley Software Distribution (BSD) init systems. The name systemd adheres to the Unix convention of naming daemons by appending the letter d.

*ssh-agent*

SSH is a protocol allowing secure remote login to a computer on a network using public-key cryptography. ... Therefore, users run a program called ssh-agent that runs the duration of a local login session, stores unencrypted keys in memory, and communicates with SSH clients using a Unix domain socket.

### where to start

Create a systemd user service, by putting the following to ~/.config/systemd/user/ssh-agent.service:

{% highlight bash %}
[Unit]
Description=SSH key agent

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
{% endhighlight %}

Setup shell to have an environment variable for the socket (.bash_profile, .zshrc, ...):

{% highlight bash %}
echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >> ~/.bash_profile
{% endhighlight %}

Enable the service, so it'll be started automatically on login, and start it:

{% highlight bash %}
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
{% endhighlight %}

Add the following configuration setting to your ssh config file ~/.ssh/config (this works since SSH 7.2):

{% highlight bash %}
echo 'AddKeysToAgent  yes' >> ~/.ssh/config
{% endhighlight %}

This will instruct the ssh client to always add the key to a running agent, so there's no need to ssh-add it beforehand.
