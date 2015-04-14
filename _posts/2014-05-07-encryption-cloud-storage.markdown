---
layout: post
status: publish
published: true
title: Encryption for Cloud Storage
date: !binary |-
  MjAxNC0wNS0wNyAwNTo1NDo1MyAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0wNyAwNTo1NDo1MyAtMDQwMA==
---

With all the recent talk about how NSA is reading archived email I thought it might be worthwhile to share how I secure my archived email with the wider audience.

Being the data pack rat I've managed to keep a copy of my Inbox for the last 5 years. As you can imagine this gives me quite a large piece of data. I wanted to keep a copy of this online at all times but ensure that I was the only one able to view it contents.

Taking a look around at ways to secure email I'm&nbsp;surprised to see that securing of email is&nbsp;focused on when both parties&nbsp;engage in 2 way crypto. No one seems to be interested in ways to secure email that was originally sent insecurely but hold enough value over time that you want to keep it a secret.

The thought was to use online file storage to keep a copy of my encrypted inbox. I took a look at the top 3 online file storage providers and was surprised to find only Dropbox met all the requirements:

* Needs delta syncing support: How can google drive not support this? I'm going to end up with a large single file that will contain all my email encrypted. Having to sync this file in it's entirety every time i make a change isn't going to work
* Needs large file support: 2G? Really Microsoft?

However, I'm cheap and Dropbox is quite expensive. I would prefer to not spend money when I don't have too (who doesn't). So looking around further I found&nbsp;BitTorrent Sync!

Now I have my method for storage syncing.

BT Sync also comes with an Android client. This means I can install it on my desktop, phone and laptop and have my mail automatically synced between all my devices. It also means that if my laptop is off in my bag and I'm working on my desktop my phone acts as a carrier for my data (make sure you encrypt your phone!).

I then grabbed a copy of Thunderbird and downloaded all my email from my current providers.

Grabbing a copy of&nbsp;TrueCrypt&nbsp;I created an encrypted volume. I'll let you choose how paranoid you want to be when setting up this volume. It has the ability to hide volumes etc. Once I'd &nbsp;copied thunderbirds email tree into the volume I put the truecrypt volume into my BT Sync directory and I'm done!

I now have an encrypted archived email accessible from anywhere that only I can read.
