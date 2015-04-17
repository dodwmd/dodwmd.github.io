---
layout: post
title: Ubuntu LTS "trusty" affected kernel bug
description: Kernel bug plagues java users on current Ubuntu LTS
headline: Ubuntu LTS "trusty" affected kernel bug             # Will appear in bold letters on top of the post
---

Turns out the kernel that's currently shipping with trusty LTS causes most java applications to 'bork' when starting up.

This is due to a kernel bug that was introduced in the Linux kernel around 3.12 and then fixed in 3.13.5. Unfortunately Ubuntu 14.04-LTS ships with kernel 3.13.0.

I'd suggesting holding off on that upgrade for a little while longer.

If you already took the plunge maybe the mainline kernel build might help you out.


### installation

For 32-Bit Systems

{% highlight bash %}
sudo dpkg -i http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-headers-3.13.5-031305-generic_3.13.5-031305.201402221823_i386.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-headers-3.13.5-031305_3.13.5-031305.201402221823_all.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-image-3.13.5-031305-generic_3.13.5-031305.201402221823_i386.deb
sudo reboot
{% endhighlight %}
 
For 64-Bit Systems

{% highlight bash %}
sudo dpkg -i http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-headers-3.13.5-031305-generic_3.13.5-031305.201402221823_amd64.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-headers-3.13.5-031305_3.13.5-031305.201402221823_all.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13.5-trusty/linux-image-3.13.5-031305-generic_3.13.5-031305.201402221823_amd64.deb
sudo reboot
{% endhighlight %}
 
## further reading

<a href="https://www.kernel.org/pub/linux/kernel/v3.0/ChangeLog-3.13.5">https://www.kernel.org/pub/linux/kernel/v3.0/ChangeLog-3.13.5</a>
