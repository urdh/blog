# frozen_string_literal: true

ruby '~> 3.4.7'
source 'https://rubygems.org'
gem 'jekyll', '~> 4.4'

group :jekyll_plugins do
  gem 'jekyll-sitemap', '>= 1.4.0'
  gem 'kramdown-parser-gfm'
  gem 'rouge'
end

group :development, :test do
  gem 'colorize'
  gem 'html5_validator'
  gem 'html-proofer', '>= 3.17.0'
  gem 'nokogiri', '>= 1.10.5'
  gem 'w3c_validators', '>= 1.3.3'
end

group :development, :lint do
  gem 'base64'
  gem 'rubocop'
end

group :development do
  gem 'ruby-lsp'
end
