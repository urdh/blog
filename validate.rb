#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'w3c_validators'
require 'colorize'
require 'open-uri'

IGNORED_FILES = [
    '_site/stylesheets/normalize.css'
]

class XMLValidator < W3CValidators::Validator
    def validate_file(file)
        if file.respond_to? :read
            src = file.read
            file_path = file.path ||= nil
        else
            src = read_local_file(file)
            file_path = file
        end

        begin
            document = Nokogiri::XML(src)
            @results = if document.xpath('*/@xsi:schemaLocation').empty?
                W3CValidators::Results.new({:uri => nil, :validity => true})
            else
                schema_uri = document.xpath('*/@xsi:schemaLocation').to_s.split[1]
                schema = Nokogiri::XML::Schema(open(schema_uri).read)
                is_valid = schema.validate(document).empty?
                W3CValidators::Results.new({:uri => nil, :validity => is_valid})
            end
        rescue Nokogiri::SyntaxError
            @results = W3CValidators::Results.new({:uri => nil, :validity => false})
        end
        @results
    end
end

failed = 0
passed = 0
skipped = 0

# ...
Dir.glob("_site/**/*") do |file|
    next if File.directory?(file)
    next if IGNORED_FILES.include? file

    validator = case File.extname(file)
    when '.html'
        W3CValidators::NuValidator.new
    when '.xml'
        if File.basename(file) == 'atom.xml'
            W3CValidators::FeedValidator.new
        else
            XMLValidator.new
        end
    when '.css'
        W3CValidators::CSSValidator.new
    else
        nil
    end

    begin
        if validator.validate_file(file).is_valid?
            puts file.colorize(:green)
            passed += 1
        else
            puts file.colorize(:red)
            failed += 1
        end
    rescue
        puts file
        skipped += 1
    end
end

puts "\n"
puts "#{skipped} files skipped due to missing or broken validators." if skipped > 0
puts ""
puts "#{passed} files pass validation.".colorize(:green)
puts "#{failed} files failed to validate!".colorize(:red) if failed > 0
exit failed
