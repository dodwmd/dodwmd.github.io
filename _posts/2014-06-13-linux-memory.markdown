---
layout: post
status: publish
published: true
title: Linux Memory
date: !binary |-
  MjAxNC0wNi0xMyAxMzo1Nzo0MyAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNi0xMyAwMzo1Nzo0MyAtMDQwMA==
---
So I thought I'd cover off some understanding I have about how Linux handles memory. Quite often I've been asked to take a look at a server to judge whether its memory should be upgraded to handle its workload. To get started first we need a basic understanding of how the kernel handles memory and what all the different measures are.

Generally the memory of your Linux server will be allocated to the different tasks that are running. Some of that memory will be used for storing data cache from a disk read and some will be holding data for processes that aren't executing at that specific moment.

Processing in Linux have their own Virtual Address Space (VIRT). This is a total of all the memory that the process is using at the moment. However, the VIRT is usually larger than what the 'resident memory' (RES), which is the actually used memory that the process is using. The RES is the processes data that is currently sitting in RAM. You also have a type of memory called shared memory (SHR). SHR memory is memory that is shared between multiple instances of the same process. So when you want to calculate the memory a process is using you could add RES and its SHR. However if you have multiple child processes all using the same shared memory you would calculate it via (RES + RES + RES ... + SHR)

The difference between RES and VIRT comes about due to how memory is handled by the kernel. Memory isn't handled via blocks, it's handled via pages. Memory pages can have two different states active or inactive. Active pages are memory pages that are currently 'in-use'. Pages that are 'in-active' is everything else. This means in-active pages can be swapped out to disk if memory starts to run out. But first the kernel will move the pages to cache. Cache acts as a buffer between active memory and swap. This means if an application was to run, terminate and then need to be ran again the kernel can pull it's memory out of cache and reuse the pages without having to access the disk. 

We also have another type of memory called disk buffers. If for whatever reason the kernel decides it wants to write memory to disk (save file/memory to swap space) it first writes the data to the disk buffers. This is how the kernel will queue disk writing (and why turning off a running linux server is always a bad idea without first shutting down!). It enables the kernel to report to the process the data has been written to disk but not bottle neck the application if disk IO is under load. 

All of this memory management is happening at a very fast rate. And trying to follow it in true real-time would take a human a very long time. To summarize this tools like top, mrtg and munin take snapshots in time of what the memory is doing at certain points in time.

By the time it reports the state of the memory the memory has already been changed, so to get a good understanding of memory we should look at what it's doing over a long period of time. Spikes in memory usage shouldn't be much of a concern but long time overuse of memory should be addressed.

Processes can access large amounts of memory at anyone time but most don't actively use that memory so the kernel will cache it away for when it's actually needed and allow other applications to be ran to pull in more data. Processes however can flag memory to be 'locked' which tells the kernel not to allow it to cache this memory away. Processes like java for example want to self manage memory rather than leaving it to the kernel to handle.

So the amount of memory "used" by an application and the amount of memory it "has" are two completely different things. Much of an applications data space is actually in the cache, not in the "core" memory, but since the cache is in RAM most of the time it's instantly available and just needs "activating" to become "core" memory. That is unless it's been swapped out to disk, then it then needs unswapping (which might be fast if it's in the buffer).

Due to the high-speed nature of memory management and the fact that the figures are always changing, the numbers may even change part way through calculating what they are, so it's never possible to exactly say "this is how much memory is in use" from a user's perspective. The 'meminfo' is a snapshot in time provided by the kernel, but since it's the kernel that's executing then it's not necessarily showing the real state of any one processes memory usage, as no process is actively executing at that time - it's between processes.

At the end of the day it really doesn't matter. What matters is not how much memory you have "free", but how much swap space you have used, and how often swap space is being accessed. It's swapping that slows a system down, not lack of memory (though lack of memory causes excess swapping). If you have lots of used memory, but you're not using any (or very little) swap space, then things are normal. Free memory in general isn't desirable, and is often purely transitional anyway, in that it was in use for one purpose, but hasn't yet been allocated for another - for instance it was cache memory, and it's been swapped to disk, but it hasn't yet been used for anything else, or it was disk buffers, the buffers have been flushed to disk, but no application has requested it for cache yet.

All of this investigation into memory usage usually happens 'after the fact' so having good logging setup that can highlight what was happening to your system during high load is a must. Personally I use munin to graph lots of useful information about the servers I manage.


## further reading

<a href="http://munin-monitoring.org/" target="_blank">http://munin-monitoring.org/</a>
