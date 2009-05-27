module Tick::Bin::Set
  DESCRIPTION = 'update properties of tick objects'

  module_function

  def parser(bin, opt)
    bin.on('-s', '--status STATUS'){|v| opt[:status] = v }
    bin.on('-n', '--name STRING'){|v| opt[:name] = v }
    bin.on('-d', '--description STRING'){|v| opt[:description] = v }
    bin.on('-t', '--tags tag1,tag2,...', Array){|v| opt[:tags] = v }
    bin.on('-a', '--author STRING'){|v| opt[:author] = v }
  end

  def run(bin, options)
    if tick_id = bin.args.first
      bin.repo.milestones.each do |milestone|
        milestone.tickets.each do |ticket|
          next unless tick_id == ticket.tick_id

          if ticket.update(options)
            puts "Updated #{ticket.tick_name}"
          end
        end
      end

      exit
    else
      puts "Need a tick_id to operate on"
      exit 1
    end
  end
end
