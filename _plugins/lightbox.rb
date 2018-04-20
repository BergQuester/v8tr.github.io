module Jekyll
    class LightboxTag < Liquid::Tag
      def initialize(tag_name, text, token)
        super
        @text = text
      end
  
      def render(context)
        path, title, alt = @text.split(',').map(&:strip)
        %{<a href="/img/#{path}" rel="lightbox" title="#{title}"><img src="/img/#{path}" alt="#{alt || title}" /></a>}
      end
    end
  end
  
  Liquid::Template.register_tag('lightbox', Jekyll::LightboxTag)