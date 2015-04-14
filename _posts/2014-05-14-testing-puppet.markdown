---
layout: post
status: publish
published: true
title: Testing Puppet
date: !binary |-
  MjAxNC0wNS0xNCAxNjo1NDoxOCAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNS0xNCAwNjo1NDoxOCAtMDQwMA==
---
I'd like to cover some information about how you can test puppet modules. I've seen a lot of companies creating puppet modules and testing them via direct deployments onto machines. Or worst yet making changes to manifests without any testing at all. The world of puppet testing can seem quite daunting but with the following paragraphs I hope to show you that you can make some very small changes to how you develop puppet modules that will hopefully save you from some very bad situations.


### syntax checking

At the minimum on the checking list, you can use the puppet client to check the syntax of your modules. It's very easy for simple typos to break a puppet run. When editing a manifest file simply type the following (using init.pp as an example):

{% highlight bash %}
dodwmd@puppet:~/puppet/modules/postgresql/manifests$ puppet parser validate init.pp
Error: Could not parse for environment production: Syntax error at end of file; expected '}' at /etc/puppet/modules/postgresql/manifests/init.pp:631
dodwmd@puppet:~/puppet/modules/postgresql/manifests$
{% endhighlight %}
 
As you can see I've left out the '}' somewhere around line 631.

### lint

Once we're happy that the syntax is correct in our file we may want to work on how we've written the file so other developers are able to understand it. We can do this with a tool called '<a href="http://puppet-lint.com/" title="puppet-lint" target="_blank">puppet-lint</a>'. Once it's installed we can once again run a test against our init.pp file:

{% highlight bash %}
dodwmd@puppet:~/puppet/modules/postgresql/manifests$ puppet-lint init.pp
WARNING: line has more than 80 characters on line 20
WARNING: line has more than 80 characters on line 36
WARNING: line has more than 80 characters on line 37
WARNING: line has more than 80 characters on line 55
WARNING: line has more than 80 characters on line 59
WARNING: line has more than 80 characters on line 125
WARNING: line has more than 80 characters on line 147
WARNING: line has more than 80 characters on line 158
WARNING: line has more than 80 characters on line 423
WARNING: line has more than 80 characters on line 431
WARNING: line has more than 80 characters on line 462
WARNING: line has more than 80 characters on line 463
WARNING: line has more than 80 characters on line 487
WARNING: line has more than 80 characters on line 622
dodwmd@puppet:~/puppet/modules/postgresql/manifests$
{% endhighlight %}

 
### jenkins and puppet-lint

A fun way to encourage a team to work on lint warnings is to create a Jenkins job that will graph the warnings over time to encourage members to get rid of them. Here is a quick run down that will help you do some CI testing on your puppet modules tree.

* Install the "Warnings" plugin from the Jenkins "Manage Jenkins->Manage Plugins" page
* Update the Rakefile in the root directory of puppet module/tree to contain the following to invoke puppet-lint with a specific log format

{% highlight ruby %}
# /etc/puppet/Rakefile
LINT_IGNORES = ['rvm']
namespace :lint do
  desc "Check puppet module code style."
  task :ci do
    begin
      require 'puppet-lint'
    rescue LoadError
      fail 'Cannot load puppet-lint, did you install it?'
    end
    success = true
    linter = PuppetLint.new
    linter.configuration.log_format =
        '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'
    lintrc = ".puppet-lintrc"
    if File.file?(lintrc)
      File.read(lintrc).each_line do |line|
        check = line.sub(/--no-([a-zA-Z0-9_]*)-check/, '\1').chomp
        linter.configuration.send("disable_#{check}")
      end
    end
    FileList['**/*.pp'].each do |puppet_file|
      if puppet_file.start_with? 'modules'
        parts = puppet_file.split('/')
        module_name = parts[1]
        next if LINT_IGNORES.include? module_name
      end
      puts "Evaluating code style for #{puppet_file}"
      linter.file = puppet_file
      linter.run
      success = false if linter.errors?
    end
    abort "Checking puppet module code style FAILED" if success.is_a?(FalseClass)
  end
end
{% endhighlight %}

* Create a new Jenkins Project and have Jenkins pull a copy of your modules out of your source repository
* Configure the project to execute a new Rake task as part of the build (rake lint:ci)
* Add a 'Post-build Action' to 'Scan console log' using the 'Puppet-lint' parser
* Then just run a build

Once the build finishes successfully you should get some interesting statistics on the Jenkins Project's homepage. Fix some of the errors and it'll be graphed over time. You might also want to install some git hooks that will automatically kick off this job on a commit.


### rspec

I don't want to cover that much of rspec because the tutorial at <a href="http://rspec-puppet.com/tutorial/" title="rspec tutorial" target="_blank">http://rspec-puppet.com/tutorial/</a> covers anything that I'd touch on. But it has to be mentioned, as catalog testing is a must for puppet module developers. If you want to go even further with your testing maybe beaker is for you!

### beaker

Each of the methods described above push modules further to ensure you're delivering the highest quality code to customers. beaker is a framework by puppetlabs to spin up dedicated test instances and actually attempt to apply the manifest and rspec tests to the instances. This is a method to fully test puppet manifests without applying the changes to live production servers. The following hyper visor methods are supported:

* <a href="http://www.vmware.com/au/products/vsphere-hypervisor" target="_blank">VMWare vSphere</a>
* <a href="http://www.vmware.com/products/fusion" target="_blank">VMWare Fusion</a>
* <a href="https://aws.amazon.com/ec2/" target="_blank">EC2</a>
* <a href="http://en.wikipedia.org/wiki/Solaris_Containers" target="_blank">Solaris via Zones/Containers</a>
* <a href="http://www.vagrantup.com/" target="_blank">Vagrant</a>
* <a href="https://cloud.google.com/products/compute-engine/" target="_blank">Google Compute Engine</a>
* <a href="http://docker.io/" target="_blank">Docker</a>

The following walk through is going to focus on using EC2 to spin up instances for testing puppet manifests. Let's get started!
We need to install puppetlabs_spec_helper via:

{% highlight bash %}
$ git clone git://github.com/puppetlabs/puppetlabs_spec_helper.git
$ cd puppetlabs_spec_helper
$ rake package:gem
$ gem install pkg/puppetlabs_spec_helper-*.gem
{% endhighlight %}
 
Lets grab an example puppet module that already has most of the required files needed for our testing.

{% highlight bash %}
$ git clone https://github.com/puppetlabs/puppetlabs-mysql.git mysql
$ cd mysql
{% endhighlight %}

Take a look in spec/acceptance and you can find pre-written acceptance tests.

Now we need to describe the nodes that are going to be used to test the mysql module. You need to describe the node(s) in the nodesets directory under the acceptance sub-directory.

Lets change the default mysql/spec/nodesets/default.yml which describes the instances to startup for our module testing:

{% highlight bash %}
# cat mysql/spec/nodesets/default.yml
HOSTS:
  ubuntu-1204-64-1:
    roles:
      - master
      - database
      - dashboard
      - agent
    vmname: ubuntu-dodwell
    platform: ubuntu-12.04-amd64
    amisize: c1.medium
    hypervisor: ec2
    snapshot: foss
  ubuntu-1204-64-2:
    roles:
      - agent
    vmname: ubuntu-dodwell
    platform: ubuntu-12.04-amd64
    amisize: c1.medium
    hypervisor: ec2
    snapshot: foss
CONFIG:
  nfs_server: none
  consoleport: 443
{% endhighlight %}
 
This is the file that describes where we want to run our test instances. Documentation has been created <a href="https://github.com/puppetlabs/beaker/wiki/Creating-A-Test-Environment">here</a> that describes how to support different hypervisors.

We will also need a file in config/images_templates called ec2.yaml that describes how the 'vmname' (Host/SUT) is tied to a AMI.

{% highlight bash %}
# mysql/config/images_templates/ec2.yaml
AMI:
  ubuntu-ap:
    :image:
      :foss: ami-4d51ca77
    :region: ap-southeast-2
{% endhighlight %}
 
> Hosts, or SUTs (Systems Under Test), must meet the following requirements:
> 
> * The SUT will need a properly configured network, hosts will need to be able to reach each other by hostname.
> * On the SUT, you must configure passwordless SSH authentication for the root user.
> * The SUT must have the ntpdate binary installed
> * The SUT must have the curl binary installed
> * On Windows, Cygwin must be installed (with curl, sshd, bash) and the necessary windows gems (sys-admin, win32-dir, etc).
> * FOSS install: you must have git, ruby, and rdoc installed on your SUT.

Take a read of <a href="http://dodwell.us/packer-io/">this blog post</a> on how to use packer.io to create custom AMI's.

The last step of config will be to ensure fog.io is set up. Create a file in your home directory called ~/.fog and put your EC2 credentials inside it:

{% highlight bash %}
# ~/.fog
:default:
  :aws_access_key_id: XXXXXXXXXXXXXXXXX
  :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXX
{% endhighlight %}
 
Let's give it a spin.

{% highlight bash %}
~/mysql$ bundle exec beaker --log-level debug --hosts spec/acceptance/nodesets/default.yml --tests spec/acceptance
Hypervisor for ubuntu-1204-64-1 is ec2
Hypervisor for ubuntu-1204-64-2 is ec2
Beaker::Hypervisor, found some ec2 boxes to create
aws-sdk: Iterate across all hosts in configuration and launch them
aws-sdk: Checking image ami-4d51ca77 exists and getting its root device
[AWS EC2 200 0.313706 0 retries] describe_images(:image_ids=>["ami-4d51ca77"])
aws-sdk: Image block_device_mappings: {"/dev/sda1"=>{:snapshot_id=>"snap-4a216d7e", :volume_size=>8, :delete_on_termination=>true, :volume_type=>"standard"}}
aws-sdk: Launch instance
aws-sdk: Ensure key pair exists, create if not
[AWS EC2 200 0.076698 0 retries] describe_key_pairs(:filters=>[{:name=>"key-name",:values=>["Beaker-root-puppet-dodwell-us"]}])
....
....
....
{% endhighlight %}

 
### conclusion

With each method of testing you can quickly see that more and more effort needs to go into ensuring quality puppet manifests are created. How far down the testing rabbit hole you choose to go will be something you should decide on a project by project basis. Thanks for reading!


## further reading
<a href="http://rspec-puppet.com/" target="_blank">http://rspec-puppet.com/</a>
<a href="http://hackers.lookout.com/2012/07/puppet-lint-with-jenkins/" target="_blank">http://hackers.lookout.com/2012/07/puppet-lint-with-jenkins/</a>
<a href="http://bombasticmonkey.com/2012/03/02/automatically-test-your-puppet-modules-with-travis-ci/" target="_blank">http://bombasticmonkey.com/2012/03/02/automatically-test-your-puppet-modules-with-travis-ci/</a>
<a href="https://wiki.jenkins-ci.org/display/JENKINS/Warnings+Plugin">https://wiki.jenkins-ci.org/display/JENKINS/Warnings+Plugin</a>
<a href="https://github.com/puppetlabs/beaker/wiki" target="_blank">https://github.com/puppetlabs/beaker/wiki</a>
