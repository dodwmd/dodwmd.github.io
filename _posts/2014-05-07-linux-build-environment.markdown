---
layout: post
status: publish
published: true
title: Linux Build Environment
date: !binary |-
  MjAxNC0wNS0wNyAwNjoxNToyNCAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0wNyAwNjoxNToyNCAtMDQwMA==
---
[/images/razor_overview1-300x121.jpg](https://github.com/puppetlabs/razor-server/wiki)

Most system administrators prefer to use an automated installation method to install Linux on their machines. To satisfy this need different distributions of Linux have created a number of methods (kickstart, preseed etc). This offers the advantage of allowing a single file solution that contains logic ordered questions that are asked during a typical installation.

Razor is a next-generation hardware provisioning solution developed by Puppet Labs in collaboration with EMC. It is an advanced provisioning application which can deploy both physical and virtual instances. It&rsquo;s designed to solve the problem of how to manage and deploy new systems. It does this by auditing hardware and following a set of user defined rules that determines how a system should be installed and get them to a state where configuration management workflows will take over.

Instances PXE-boot from a special Razor micro kernel image, then check in to a NoSQL backed database with inventory information then waits for further instructions. Razor will then consult user-created policy rules to choose a preconfigured model to apply to a new node. The node will then begin to follow the model&rsquo;s directions, giving feedback to Razor as it completes various steps. Models can include steps for hand-off to a central configuration management system or to any other system capable of controlling the node; such as vCenter server taking possession of ESXi systems.

Using Razor to configure Kickstart or preseed will allow administrators to easily match a profile of an instance against a set model that is able to trigger the installation of the version and type of operating system. It will also record the hardware configuration of the system and take care of all manual processes needed to create an instance.

For example, Razor produces a consistent base image with no administrator input to the install process. This ensures that the configuration management process is able to produce an image that is able to service the requirement and enables us to keep packages updated or pinned to a certain version as the project requires. One of the biggest risks associated with Razor, is that it is new to the market. There is therefore a possibility of a large amount of change to the base code or possibly support could even end. However, with backing from EMC and Puppetlabs, there is planned expansion to include more features and offer an improved functionality and usability in the coming years.

The most important part of provisioning is to produce a JeOS install of Linux that is able to be versioned and tracked over its lifetime. It is also important to produce consistent instances that can be successfully managed via configuration management with little to no administrator input. Razor allows the administrator to invest time at the start to create a framework that is able to produce customized and consistent instances. It also allows for this framework to be adopted at a later stage for the deployment of other supported operating systems and versions to both virtual and physical hardware.


## further reading

<a href="https://github.com/puppetlabs/razor-server/wiki" target="_blank">https://github.com/puppetlabs/razor-server/wiki</a>
