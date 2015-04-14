# A plugin for embedding videos from Vimeo using a simple Liquid tag, ie: {% vimeo 12345678 %}.
# Based of the Youtube plugin from http://www.portwaypoint.co.uk/jekyll-youtube-liquid-template-tag-gist/

module Jekyll
  class Vimeo < Liquid::Tag
    @@width = 560
    @@height = 420

    def initialize(name, id, tokens)
      super
      @id = id
    end

    def render(context)
      %(<center><iframe width="#{@@width}" height="#{@@height}" src="https://player.vimeo.com/video/#{@id}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe></center>)
    end
  end
end

Liquid::Template.register_tag('vimeo', Jekyll::Vimeo)
