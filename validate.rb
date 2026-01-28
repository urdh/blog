#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'nokogiri'
require 'html5_validator'
require 'w3c_validators'
require 'open-uri'
require 'html-proofer'
require 'colorize'

IGNORED_FILES = [
  '_site/stylesheets/normalize.css',
  '_site/javascript/sweet-justice.min.js',
  '_site/stylesheets/mjulb.min.css',
  '_site/javascript/mjulb.min.js',
  '_site/stylesheets/normalize.css'
].freeze

# HACK: w3c_validators doesn't provide a generic XML validator.
# We provide a replacement based on Nokogiri with compatible interface.
class XMLValidator < W3CValidators::Validator
  def validate_file(file)
    src = if file.respond_to? :read
            file.read
          else
            read_local_file(file)
          end

    begin
      document = Nokogiri::XML(src)
      @results = if document.xpath('*/@xsi:schemaLocation').empty?
                   W3CValidators::Results.new({ uri: nil, validity: true })
                 else
                   schema_uri = document.xpath('*/@xsi:schemaLocation').to_s.split[1]
                   schema = Nokogiri::XML::Schema(URI.open(schema_uri).read) # rubocop:disable Security/Open
                   errors = schema.validate(document)
                   r = W3CValidators::Results.new({ uri: nil, validity: errors.empty? })
                   errors.each { |msg| r.add_error({ message: msg.to_s }) if msg.error? }
                   r
                 end
    rescue StandardError => e
      @results = W3CValidators::Results.new({ uri: nil, validity: false })
      @results.add_error({ message: "Nokogiri threw errors on input: #{e}" })
    end
    @results
  end
end

# HACK: W3CValidators::NuValidator seems broken and the gem looks unmaintained.
# We provide our own replacement based on the html5_validator gem, with compatible interface.
class HtmlValidator < W3CValidators::Validator
  def validate_file(file)
    src = if file.respond_to? :read
            file.read
          else
            read_local_file(file)
          end

    validator = Html5Validator::Validator.new
    validator.validate_text(src)
    @results = W3CValidators::Results.new({ uri: nil, validity: validator.valid? })
    validator.errors.each { |err| @results.add_error({ message: err['message'] }) }
    @results
  end
end

# Use a custom html-proofer with less verbose output
class Reporter < HTMLProofer::Reporter
  def report
    failures.each_with_object([]) do |(_, failures), _|
      failures.each do |failure|
        path_str = blank?(failure.path) ? '' : failure.path.to_s
        line_str = failure.line.nil? ? '' : ":#{failure.line}"
        path_and_line = "#{path_str}#{line_str}"
        path_and_line = blank?(path_and_line) ? '' : "#{path_and_line}: "
        status_str = failure.status.nil? ? '' : " (status code #{failure.status})"
        puts "#{path_and_line}#{failure.description}#{status_str}".colorize(:red)
      end
    end
  end
end

# Iterate over all the site files and validate them as appropriate.
validation = Dir.glob('_site/**/*').flat_map do |file|
  # Skip ignored files and all directories
  next if File.directory?(file)
  next if IGNORED_FILES.include? file

  # Since all validators have compatible interfaces, we create the appropriate instance...
  validator = case File.extname(file)
              when '.html'
                HtmlValidator.new
              when '.xml'
                if File.basename(file) == 'atom.xml'
                  W3CValidators::FeedValidator.new
                else
                  XMLValidator.new
                end
              when '.css'
                W3CValidators::CSSValidator.new
              else
                puts file.colorize(:light_black)
                next
              end

  # ... and then run the validation.
  errors = validator.validate_file(file).errors
  if errors.empty?
    puts file.colorize(:green)
  else
    puts file.colorize(:red)
  end

  errors.map { |error| { path: file, line: error.line || 0, description: error.message } }
end.compact

unless validation.empty?
  puts "\n\n"
  validation.each do |failure|
    puts "#{failure[:path]}:#{failure[:line]}: #{failure[:description]}".colorize(:red)
  end
  puts "\n"
  puts "Validation found #{validation.length} failures!"
end

# Also run html-proofer on all generated html
puts "\n"
proofer = HTMLProofer.check_directory('./_site', { ssl_verifyhost: 2,
                                                   only_4xx: true,
                                                   url_ignore: [/doi.org/],
                                                   parallel: { in_processes: 3 },
                                                   disable_external: ARGV.include?('--disable-external') })
proofer.reporter = Reporter.new
proofer.run

exit(1) unless validation.empty?
