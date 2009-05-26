module Tick::Bin::List
  DESCRIPTION = 'List available tickets by custom criteria'
  USAGE = <<-DOC
tick list displays available tickets and provides filtering and sorting

SYNOPSIS
  tick list [OPTIONS] [Search terms]
  DOC

  module_function

  def parser(bin, opt)
    bin.on('-a', '--all',
           'Show all tickets'){|v| list_all(bin) }
    bin.on('-s', '--status STATUS',
           'Show tickets by status'){|v| list_status(bin, v) }
  end

  def run(bin, options)
    list_status(bin, 'open')
  end

  def list_all(bin)
    exit
  end

  def list_status(bin, status)
    bin.repo.milestones.each do |milestone|
      puts "Milestone: #{milestone.tick_name}"

      milestone.tickets.each do |ticket|
        puts "  Ticket: #{ticket.tick_name}"
        ticket.class.members[1..-1].each do |member|
          case member
          when :tags, 'tags'
            puts "    #{member}: #{[*ticket[member]].join(', ')}"
          else
            puts "    #{member}: #{ticket[member]}"
          end
        end
      end
    end

    exit
  end
end
