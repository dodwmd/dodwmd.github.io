---
layout: post
status: publish
published: true
title: rewrite uri to lowercase using nginx/perl, nginx/lua or apache
date: !binary |-
  MjAxNC0wNi0yMCAxNTo0MToyMSAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wNi0yMCAwNTo0MToyMSAtMDQwMA==
---
Just wanted to drop this little snippet here as I've seen a lot of people saying you can only rewrite to lower case using embedded Perl. You can indeed do this with LUA which is a little faster than the embedded Perl.

If you need to rewrite a uri '/TEST' to '/test' you can do it with the following:


### perl method

{% highlight bash %}
location ~ [A-Z] {
  perl 'sub { my $r = shift; $r->internal_redirect(lc($r->uri)); }';
}
{% endhighlight %}

OR

{% highlight bash %}
  http {
  ...
    # Include the perl module
    perl_modules perl/lib;
    ...
    # Define this function
    perl_set $uri_lowercase 'sub {
      my $r = shift;
      my $uri = $r->uri;
      $uri = lc($uri);
      return $uri;
    }';
    ...
    server {
    ...
      # As your first location entry, tell nginx to rewrite your uri,
      # if the path contains uppercase characters
      location ~ [A-Z] {
        rewrite ^(.*)$ $scheme://$host$uri_lowercase;
      }
    ...
{% endhighlight %}

 
### lua method

{% highlight bash %}
  http {
  ...
    server {
    ...
      set_by_lua $uri_lowercase "return string.lower(ngx.var.uri)";
      location ~ [A-Z] {
        try_files $uri $uri/ $uri_lowercase $uri_lowercase/ =404;
      }
    ...
{% endhighlight %}

OR

{% highlight bash %}
  http {
  ...
    server {
    ...
      location ~ [A-Z] {
        rewrite_by_lua 'ngx.exec(string.lower(ngx.var.uri))';
      }
    ...
{% endhighlight %}


### apache method
{% highlight bash %}
RewriteEngine On
RewriteMap  lc int:tolower
RewriteCond %{REQUEST_URI} [A-Z]
RewriteRule (.*) ${lc:$1} [R=301,L]
{% endhighlight %}
