module Tick::Bin::Set
  DESCRIPTION = 'update properties of tick objects'

  module_function

  def parser(bin, opt)
    bin.on('-s', '--status STATUS'){|v| opt[:status] = v }
  end

  def run(bin, options)
    if tick_id = bin.args.first
      bin.repo.milestones.each do |milestone|
        milestone.tickets.each do |ticket|
          next unless tick_id == ticket.tick_id
          ticket.update(options)
          p :updated
        end
      end

      exit
    else
      puts "Need a tick_id to operate on"
      exit 1
    end
  end
end