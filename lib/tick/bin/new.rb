module Tick::Bin::New
  DESCRIPTION = 'Create new tickets and store them'
  USAGE = <<-DOC
tick new
  DOC

  TEMPLATE = <<-FILE
<%= name %>
# You can create a new ticket by filling out the first line with the name of
# the ticket.
# You can cancel ticket creation by leaving the first line blank.
#
# The lines below are optional but also open for changes.
# Lines starting with '#' or consisting only of whitespace will be ignored.
# All ticket properties without value will also be ignored.
tags: <%= tags %>
description: <%= description %>
author: <%= author %>
  FILE

  module_function

  def parser(bin, opt)
    bin.on('-n', '--name STRING', 'Ticket name'){|v| opt[:name] = v }
    bin.on('-t', '--tags tag1,tag2,...', Array, 'Ticket tags'){|v| opt[:tags] = v }
    bin.on('-d', '--description STRING', 'Ticket description'){|v| opt[:description] = v }
    bin.on('-a', '--author STRING', 'Ticket author'){|v| opt[:author] = v }
    bin.on('-e', '--editor CMD', 'Editor to use'){|v| opt[:editor] = v }
  end

  def run(bin, options)
    require 'tempfile'
    require 'erb'

    editor = options[:editor] || ENV['EDITOR'] || 'vi'
    user_name = `git config --global --get user.name`.strip
    user_email = `git config --global --get user.email`.strip

    # template variables
    name        = options[:name]
    tags        = options[:tags]
    description = options[:description]
    author      = options[:author] || "#{user_name} <#{user_email}>"

    Tempfile.open 'tick-new-' do |tmp|
      tmp.write(ERB.new(TEMPLATE).result(binding))
      tmp.flush
      system(editor, tmp.path)
      tmp.rewind
      create_ticket(bin, tmp)
    end

    exit
  end

  def create_ticket(bin, io)
    properties = parse_ticket(io)
    ticket = bin.repo.milestone.create_ticket(properties)
    pp ticket
  end

  def parse_ticket(io)
    properties = {}
    ticket_name = io.gets

    if ticket_name.nil? or ticket_name.empty?
      puts "Ticket creation aborted, no title given"
      exit 1
    else
      properties[:name] = ticket_name.strip
    end

    while line = io.gets
      case line
      when /^[#\s]*$/
      when /^(\w+)\s*:\s*(\S.+)\s*$/
        key, value = $1, $2

        case key
        when 'tags'
          properties[:tag] = value.split(/\s*,\s*/)
        else
          properties[key.to_sym] = value
        end
      end
    end

    return properties
  end
end
