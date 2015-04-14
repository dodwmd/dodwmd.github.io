---
layout: post
status: publish
published: true
title: Using Nginx to proxy private Amazon S3 web services
date: !binary |-
  MjAxNC0wNi0wNiAxNTo0ODoyOSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNi0wNiAwNTo0ODoyOSAtMDQwMA==
---
I thought I'd share how I set up Nginx to proxy a private S3 bucket.

I wanted to be able to password protect the contents of a bucket and without allowing any owner information of the bucket from leaking to the web user.

A simple configuration can be used if you want to serve objects that are public:

{% highlight bash %}
location ~* ^/s3/(.*) {
  resolver               172.31.0.2 valid=300s;
  resolver_timeout       10s;
  set $s3_bucket        'your_bucket.s3.amazonaws.com';
  set $url_full         '$1';
  proxy_http_version     1.1;
  proxy_set_header       Host $s3_bucket;
  proxy_set_header       Authorization '';
  proxy_hide_header      x-amz-id-2;
  proxy_hide_header      x-amz-request-id;
  proxy_hide_header      Set-Cookie;
  proxy_ignore_headers   "Set-Cookie";
  proxy_buffering        off;
  proxy_intercept_errors on;
  proxy_pass             http://$s3_bucket/$url_full;
}
{% endhighlight %}

To setup nginx to use a private bucket is a little more work.

First we need to add in a few extra modules to the standard Nginx. Most of these modules have already been included in the nginx-extras package, however I'll need to grab a copy of the latest source Ubuntu package, modify the rules file and repackage it so I can deploy it using my own apt repository.

We need the following modules:

* set-misc-nginx-module
* ngx_devel_kit

> ngx_devel_kit is a dependency for set-misc-nginx-module. 

{% highlight bash %}
add-apt-repository ppa:nginx/unstable
apt-get update
cd /usr/src
apt-get build-dep nginx
apt-get source nginx
{% endhighlight %}
 
We should now have a copy of the latest Nginx source package unpacked into /usr/src. Lets grab the module we want to install.

{% highlight bash %}
git clone https://github.com/openresty/set-misc-nginx-module.git debian/modules/set-misc-nginx-module
{% endhighlight %}
 
The debian package already includes the nginx-development-kit. Lets modify the debian/rules file.
Under the 'extras_configure_flags' lets ensure '--add-module=$(MODULESDIR)/nginx-development-kit' already exists and add '--add-module=$(MODULESDIR)/set-misc-nginx-module'.

{% highlight bash %}
....
extras_configure_flags := \
                        $(common_configure_flags) \
                        --with-http_addition_module \
                        --with-http_dav_module \
                        --with-http_flv_module \
                        --with-http_geoip_module \
                        --with-http_gzip_static_module \
                        --with-http_image_filter_module \
                        --with-http_mp4_module \
                        --with-http_perl_module \
                        --with-http_random_index_module \
                        --with-http_secure_link_module \
                        --with-http_spdy_module \
                        --with-http_sub_module \
                        --with-http_xslt_module \
                        --with-mail \
                        --with-mail_ssl_module \
                        --add-module=$(MODULESDIR)/nginx-auth-pam \
                        --add-module=$(MODULESDIR)/nginx-cache-purge \
                        --add-module=$(MODULESDIR)/nginx-dav-ext-module \
                        --add-module=$(MODULESDIR)/nginx-echo \
                        --add-module=$(MODULESDIR)/ngx-fancyindex \
                        --add-module=$(MODULESDIR)/nginx-http-push \
                        --add-module=$(MODULESDIR)/nginx-lua \
                        --add-module=$(MODULESDIR)/nginx-upload-progress \
                        --add-module=$(MODULESDIR)/nginx-upstream-fair \
                        --add-module=$(MODULESDIR)/ngx_http_substitutions_filter_module \
                        --add-module=$(MODULESDIR)/nginx-development-kit \
                        --add-module=$(MODULESDIR)/set-misc-nginx-module
....
{% endhighlight %}
 
Now lets save this and update the changelog making a local package.

{% highlight bash %}
dch --local dodwmd
{% endhighlight %}
 
Edit the changelog in vi and include what has been changed and by whom.
Now lets repackage.

{% highlight bash %}
dpkg-buildpackage -us -uc
{% endhighlight %}
 
We now have .deb packages we can place on our apt repo for our webservers to use.
Once you've copied the packages to your repo and installed the 'nginx-extras' package on the webservers you can use the following configuration code snippet in nginx:
{% highlight bash %}
...
  location ~* ^/s3/(.*) {
    set $bucket           '<REPLACE WITH YOUR S3 BUCKET NAME>';
    set $aws_access       '<REPLACE WITH YOUR AWS ACCESS KEY>';
    set $aws_secret       '<REPLACE WITH YOUR AWS SECRET KEY>';
    set $url_full         "$1";
    set_by_lua $now       "return ngx.cookie_time(ngx.time())";
    set $string_to_sign   "$request_method\n\n\n\nx-amz-date:${now}\n/$bucket/$url_full";
    set_hmac_sha1          $aws_signature $aws_secret $string_to_sign;
    set_encode_base64      $aws_signature $aws_signature;
    resolver               172.31.0.2 valid=300s;
    resolver_timeout       10s;
    proxy_http_version     1.1;
    proxy_set_header       Host $bucket.s3.amazonaws.com;
    proxy_set_header       x-amz-date $now;
    proxy_set_header       Authorization "AWS $aws_access:$aws_signature";
    proxy_buffering        off;
    proxy_intercept_errors on;
    rewrite .* /$url_full break;
    proxy_pass             http://s3.amazonaws.com;
  }
{% endhighlight %}


## further reading

<a href="http://s3.amazonaws.com/doc/s3-developer-guide/RESTAuthentication.html" target="_blank">http://s3.amazonaws.com/doc/s3-developer-guide/RESTAuthentication.html</a>
