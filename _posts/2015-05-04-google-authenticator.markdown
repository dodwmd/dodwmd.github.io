---
layout: post
title: "Google Authenticator for SSH"
description: Add Google Authenticator support to SSH 
headline: Setup Google Authenticator in SSH             # Will appear in bold letters on top of the post
modified: 2015-05-04                # Date
category: security
tags: []
image: 
  feature: openssh.png
comments: false
mathjax:
---
[Previously](http://dodwell.us/security/ssh-setup/) I posted on how to make some changes to SSH to improve it's security. One of the configuration options I said to change was to disable password authentication. I want to cover how you can keep password authentication enable by using 2-factor authentication powered by Google Authenticator.

### what is it? 

> Two-factor authentication (also known as 2FA) provides unambiguous identification of users by means of the combination of two different components. These components may be something that the user knows, something that the user possesses or something that is inseparable from the user. A good example from everyday life is the withdrawing of money from a cash machine. Only the correct combination of a bank card (something that the user possesses) and a PIN (personal identification number, i.e. something that the user knows) allows the transaction to be carried out. Two-factor authentication is a type of multi-factor authentication.
>
> -- <a href="http://en.wikipedia.org/wiki/Two_factor_authentication">http://en.wikipedia.org/wiki/Two_factor_authentication</a>

### why would i give my keys to google?

Google Authenticator's time-based one-time password (TOTP) system doesn't "phone home" to Google all the work happens on your server. By enabling TOTP your account information isn't actually shared with Google nor do you require a Google account. The key exchange is done via a pre-shared key that's used with the current UTC timestamp to generate a one time password that you use to authenticate to the server.

The project is also open source and you can review the code [here](http://code.google.com/p/google-authenticator/).

### install google authenticator

To implement multifactor authentication with Google Authenticator, you'll need the open-source Google Authenticator PAM module. PAM stands for 'pluggable authentication module' it's a way to easily plug different forms of authentication into a Linux system.

Ubuntu's software repositories contain an easy-to-install package for the Google Authenticator PAM module. If your Linux distribution doesn't contain a package for this, you'll have to download it from the Google Authenticator downloads page on Google Code and compile it yourself.

To install the package on Ubuntu, run the following command:

{% highlight bash %}
$ sudo apt-get install libpam-google-authenticator
{% endhighlight %}

(This will only install the PAM module on your system you will have to activate it for SSH logins manually.)

### create an authentication key

Now that the PAM module has been installed you will need to generate a authentication key. This is the pre-shared key that's used as part of the seed to the TOTP.

Login as the user you wish to use 2FA and type:

{% highlight bash %}
$ google-authenticator
{% endhighlight %}

After answering 'yes' to the question if you want authentication tokens to be time-based, it should produce some output that looks like the following:

{% highlight bash %}
Do you want authentication tokens to be time-based (y/n) y

Your new secret key is: S5JUU47ZVAE2IX4R
Your verification code is 983290
Your emergency scratch codes are:
  97505839
  65363572
  25577686
  65028652
  13575975

Do you want me to update your "/home/USERNAME/.google_authenticator" file (y/n) y
{% endhighlight %}

Google Authenticator will present you with a secret key and several 'emergency scratch codes'. Write down the emergency scratch codes somewhere safe they can only be used one time each, and they're intended for use if you lose your phone.

You will also need to add the 'secret key' to your phone's Google Authenticator app.

Once you've added the 'secret key' to your phones Google Authenticator app, Answer 'yes' to updating your .google_authenticator file and then answer the following questions:

{% highlight bash %}
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. Do you want to do so (y/n) n

If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
{% endhighlight %}

### enable Google Authenticator

Now that you've setup everything it's time to actually enable the PAM module. You can do this with the following:

{% highlight bash %}
$ echo 'auth required pam_google_authenticator.so' | sudo tee -a /etc/pam.d/sshd
{% endhighlight %}

You will also need to edit /etc/ssh/sshd_config. Look for the 'ChallengeResponseAuthentication' line and enable it.

{% highlight bash %}
ChallengeResponseAuthentication yes
{% endhighlight %}

If you followed my [previous post](https://dodwell.us/security/ssh-setup/), you will also need to update 'PasswordAuthentication' from 'no' to 'yes'.

{% highlight bash %}
PasswordAuthentication yes
{% endhighlight %}

Finally, restart the SSH server so your changes will take effect:

{% highlight bash %}
$ sudo service ssh restart
{% endhighlight %}

### testing

You can now simply ssh to localhost and see if you get the 2FA.

{% highlight bash %}
$ ssh localhost
Password:
Verification code:
$
{% endhighlight %}
