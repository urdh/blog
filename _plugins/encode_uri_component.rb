# frozen_string_literal: true

require 'liquid'
require 'uri'

module Jekyll
  # Helper for URI-encoding a string according to the HTML5 specification
  module EncodeURIComponent
    def encode_uri_component(content)
      URI.encode_www_form_component(content)
    end
  end
end

Liquid::Template.register_filter(Jekyll::EncodeURIComponent)
