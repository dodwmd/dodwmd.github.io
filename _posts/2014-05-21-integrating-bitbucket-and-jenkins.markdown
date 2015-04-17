---
layout: post
status: publish
published: true
title: Integrating Bitbucket and Jenkins
date: !binary |-
  MjAxNC0wNS0yMSAxNTowNzo1NSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0yMSAwNTowNzo1NSAtMDQwMA==
---
I just had a little gotcha using Jenkins and trying to integrate it so that bitbucket can use git hooks to kick off builds on commits. So I thought I'd share how I managed to get it all working as to me it wasn't that clear.

Firstly I'll assume you have a secured Jenkins instance setup and a repository on bitbucket.

Once it's working login to your jenkins instance as the user you wish to use to kick off builds and manually build a job you've configured. I'd suggest creating a user for functions like this. Lets call him 'dodwmd_jenkins'

You then need to grab the 'API token' for this user. To do that, from the Jenkins home page, click on People, click on the desired user, click configure on the left, then, finally, click on the API Token button. Lets say it's 'ji0foi6jeseGhi4f'

Now in another browser tab open bitbucket and browse to your repository. Click settings and select 'Hooks'. From the dropdown, select 'Jenkins', click 'Add Hook', then click on the edit link next to the newly created hook and fill in the form:

<table>
<tbody>
<tr>
<td><strong>endpoint</strong></td>
<td>The endpoint needs to be the publicly accessible URL to your jenkinsinstance. But it needs to include the username we used before and the 'API token' in our other tab. So an example would be http://dodwmd_jenkins:ji0foi6jeseGhi4f@jenkins.dodwell.us/</td>
</tr>
<tr>
<td><strong>module name</strong></td>
<td>leave this blank</td>
</tr>
<tr>
<td><strong>project name</strong></td>
<td>Set this to be the name of the job you setup in jenkins. Don't worry about encoding the name bitbucket will do this for us.</td>
</tr>
<tr>
<td><strong>token</strong></td>
<td>set this to be the token you setup in your job when you ticked the 'Trigger builds remotely (e.g., from scripts)' box</td>
</tr>
</tbody>
</table>

Click save

Push a change to your bitbucket repo and you should see a build running on your jenkins install!


### troubleshooting

You can check if your hook endpoint is working correctly:
{% highlight bash %}
$ curl -XPOST 'http://dodwmd_jenkins:ji0foi6jeseGhi4f@jenkins.dodwell.us/job/buildstuff/build?token=thoucaephuHe2lai'
{% endhighlight %}

 
## further reading
<a href="https://wiki.jenkins-ci.org/display/JENKINS/Bitbucket+OAuth+Plugin">https://wiki.jenkins-ci.org/display/JENKINS/Bitbucket+OAuth+Plugin</a>
<a href="https://confluence.atlassian.com/display/BITBUCKET/Jenkins+hook+management">https://confluence.atlassian.com/display/BITBUCKET/Jenkins+hook+management</a>
