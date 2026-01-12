#!/usr/bin/env nix-shell
#!nix-shell -i ruby -p rubyPackages_4_0.liquid ruby_4_0
# frozen_string_literal: true

# Dependencies: gem install liquid

require 'yaml'
require 'liquid'
require 'fileutils'

# Load the rules
rules_path = File.join(__dir__, '_data', 'rules.yml')
rules = YAML.load_file(rules_path)

# Load the template
template_path = File.join(__dir__, 'dist', 'template.yml')
template_content = File.read(template_path)
template = Liquid::Template.parse(template_content)

# Clean and recreate dist/rules
dist_rules_path = File.join(__dir__, 'dist', 'rules')
FileUtils.rm_rf(dist_rules_path)
FileUtils.mkdir_p(dist_rules_path)

# Generate rule files
rules['groups'].each do |group|
  group['services'].each do |service|
    service_name = service['name'].downcase.gsub(' ', '-')
    service_dir = File.join(dist_rules_path, service_name)
    FileUtils.mkdir_p(service_dir)

    service['exporters']&.each do |exporter|
      slug = exporter['slug']
      next unless slug

      output_path = File.join(service_dir, "#{slug}.yml")

      # Render template with exporter data
      result = template.render(exporter)

      File.write(output_path, result)
      puts "  -> #{output_path}"
    end
  end
end

puts "\nDone! Generated files in dist/rules/"
