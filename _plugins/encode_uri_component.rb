# _plugins/url_encode.rb
require 'liquid'
require 'uri'

module Jekyll
  module EncodeURIComponent
    def encode_uri_component(content)
      URI.escape(content, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
  end
end

Liquid::Template.register_filter(Jekyll::EncodeURIComponent)
