---
layout: post
status: publish
published: true
title: Setting up SSH & Byobu
date: !binary |-
  MjAxNC0wNS0xMiAxMzowMzo1OSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0xMiAwMzowMzo1OSAtMDQwMA==
---
Like a lot of Unix Administrators I spend most of my day staring at a ssh session. I thought today I'd write about how I connect to servers. Currently I use a windows laptop to do most of my work. This OS was mainly chosen for a couple of reasons. 

* If I have Linux as my desktop I tend to do most of my development work on the desktop and forget to sync it to the projects I'm working on often enough. By using Windows I treat my laptop almost like a chrome book where everything is stored remotely.
* I do a lot of work with VMWare. The tools unfortunately are mainly written for Windows OS's and having to run a Virtual Machine locally just to check the status of the cluster was chewing up too much memory.
* I simply just don't like X Windows. Microsoft Windows as a client Operating System is simply superior for my needs. I would never recommend it for a server operating system but that's a whole different blog post.


### putty

To connect to servers I've been using <a href="http://www.chiark.greenend.org.uk/~sgtatham/putty/" title="PuTTY" target="_blank">PuTTY</a> for a number of years. It's a fantastic SSH client that is lightweight while in my opinion acts in a sane manner when dealing with Terminal settings across a wide range of server types. It also allows for quick highlighting (useful when showing someone on your shoulder something on the screen) and X-Windows based cut and pasting (left click to highlight, right-click to paste).


#### colour theme

I have found that the default PuTTY colour themes can be a little harsh on your eyes after a while. To solve this problem I'm using the <a href="http://ethanschoonover.com/solarized" title="SOLARIZED - Precision colors for machines and people" target="_blank">Solarized</a> colour palette (dark). 

To install solarized colour palette for PuTTY simply download the Windows registry file from <a href="https://github.com/brantb/solarized/tree/master/putty-colors-solarized" target="_blank">here.</a>. Once you've installed the registry key into the system registry you can simply open PuTTY and select the 'Solarized Dark' saved session as a template for any new sessions you wish to save.


#### ssh key management

I'm also using the PuTTY authentication agent to manage the different SSH keys I hold for the projects I'm working on. This saves me from having to enter a SSH key password every time I want to connect to a server.


#### generate ssh keys

To generate an SSH key with PuTTYgen follow these steps:

* Open the PuTTYgen program
* For Type of key to generate, select SSH-2 RSA
* Click the Generate button
* Move your mouse in the area below the progress bar. When the progress bar is full, PuTTYgen generates your key pair
* Type a pass phrase in the Key pass phrase field. Type the same pass phrase in the Confirm pass phrase field. You can use a key without a pass phrase, but this is not recommended
* Click the Save private key button to save the private key
* Right-click in the text field labelled Public key for pasting into OpenSSH ~/.ssh/authorized_keys file and choose Select All
* Right-click again in the same text field and choose Copy

To install the public key on a remote server you will need to login and paste the contents of your mouse buffer into your ~/.ssh/authorized_keys file. Making sure that the file is owned by you and the file and directory ~/.ssh/ is 'go-rwx' (chmod -R go-rwx ~/.ssh/).

Now that you have a Private key file you can open PuTTY authentication agent and simply click the 'Add Key' box and select the key file. I'd suggest setting up the agent to start on system boot and having it auto load your key files by simply running the agent with the key files as the arguments.

You will also need to enter in your username into the 'Auto-login username' field within the "Connection->Data" settings tab from within PuTTY.


### byobu

> Byobu is an enhancement for the terminal multiplexers GNU Screen or tmux that can be used to provide on-screen notification or status as well as tabbed multi window management. It is aimed at providing a better user experience for terminal sessions when connecting to remote servers.
>
> -- <a href="http://en.wikipedia.org/wiki/Byobu_(software)" title="Wikipedia" target="_blank">http://en.wikipedia.org/wiki/Byobu_(software)</a>

Ubuntu is currently setup for the byobu package to use tmux as it's backend. I prefer to use screen. To configure byobu to use screen as it's backend you just need to run the following command:

{% highlight bash %}
$ byobu-select-backend screen
{% endhighlight %}
 
I would also suggest having byobu start when you first login to the server.

{% highlight bash %}
$ byobu-launcher-install
{% endhighlight %}

 
## further reading

<a href="http://www.chiark.greenend.org.uk/~sgtatham/putty/" title="PuTTY" target="_blank">http://www.chiark.greenend.org.uk/~sgtatham/putty/</a>
<a href="http://ethanschoonover.com/solarized" title="Solarized" target="_blank">http://ethanschoonover.com/solarized</a>
<a href="http://byobu.co/" title="byobu" target="_blank">http://byobu.co/</a>
