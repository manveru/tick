module Tick
  class TicketHandler
    def read(data)
      Ticket.new(JSON.parse(data)['ticket'])
    end

    def write(data)
      data.to_json
    end
  end
end
