---
layout: post
status: publish
published: true
title: Bandwidth Theft
date: !binary |-
  MjAxNC0wOC0yNyAxNjowMzo0NiAtMDQwMA==
date_gmt: !binary |-
  MjAxNC0wOC0yNyAwNjowMzo0NiAtMDQwMA==
---
Bandwidth theft or "hotlinking" is direct linking to a web site's files (images, video, etc.). An example would be using an <img> tag to display a JPEG image you found on someone else's web page so it will appear on your own site, eBay auction listing, weblog, forum message post, etc. 

Bandwidth refers to the amount of data transferred from a web site to a user's computer. When you view a web page, you are using that site's bandwidth to display the files. Since web hosts charge based on the amount of data transferred, bandwidth is an issue. If a site is over its monthly bandwidth, it's billed for the extra data or taken offline.

A simple analogy for bandwidth theft: Imagine a random stranger plugging into your electrical outlets, using your electricity without your consent, and you paying for it. 

A few years ago hotlinking was usually only carried out by people on forums and blogs. These days companies like bing and yahoo have forgotten to be good netizens and are also hotlinking directly to content.

The problem with most methods of hotlink prevention is that they generally will ban links to your content that didn't originate from a list of allowed hosts. Although this is effective it also means that indexes will simply drop your site from search indexes and people will be unable to locate your site.

The method I wanted to share with you today overlays a large watermark on all your images so that when people do hotlink to your content they will be shown the original image but will be prompted to view the image from the original site.


### php w/imagick

I have a preference to use Imagick. I've found it's less prone to causing PHP to core than GD. I also think it's easier to work with. YMMV. 

First we need some code that will overlay our 'watermark' to the image and output the result. Lets create a 'hotlink.php' file in the root directory of our site.

{% highlight php %}
<?php
if (isset($_GET['filename'])) {
        /* Create Imagick object */
        $image = new Imagick($_GET['filename']);
        /* pull in overlay image */
        $watermark = new Imagick( 'misc/hotlink-overlay.png');
        // Check if the watermark is bigger than the image
        $image_width            = $image->getImageWidth();
        $image_height           = $image->getImageHeight();
        $watermark_width        = $watermark->getImageWidth();
        $watermark_height       = $watermark->getImageHeight();
        $padding                = 10;
        if ($image_width < $watermark_width + $padding || $image_height < $watermark_height + $padding ) {
                //small image just output image
                $output = $image->getImageBlob();
                header( "Content-Type: ". $image->getFormat() );
                echo $output;
        } else {
                // center the overlay on the orignal image
                $dest_x = ($image_width - $watermark_width)/2;
                $dest_y = ($image_height - $watermark_height)/2;
                // Draw the watermark
                $image->compositeImage($watermark,Imagick::COMPOSITE_OVER,$dest_x,$dest_y);
                $output = $image->getImageBlob();
                header( "Content-Type: ". $image->getFormat() );
                echo $output;
        }
} else {
        header( "Location: /");
}
?>
{% endhighlight %}

You will also need a image to overlay.

Create a transparent image in your graphics program of choice and enter the text that you wish (I made mine 300x300). For our purposes I added some white text with the following: 'HOTLINKED IMAGE: View the original at dodwell.us' I then stroked the text to give it a nice solid black border.

You now need nginx to redirect hot linked images to the PHP script:

{% highlight bash %}
  location ~ ^/images/ {
    valid_referers none blocked dodwell.us www.dodwell.us;
    if ($invalid_referer) {
      rewrite  ^/images/(.*)$ http://dodwell.us/hotlink.php?filename=$1 last;
    }
  }
{% endhighlight %}

Enjoy!


## further reading
<a href="http://php.net/manual/en/book.imagick.php" target="_blank">http://php.net/manual/en/book.imagick.php</a>
