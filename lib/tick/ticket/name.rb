module Tick
  class Ticket
    class Name
      Ticket::PROPERTIES['name'] = self

      def self.dump(obj)
        JSON.dump(obj.to_s)
      end

      def initialize(ticket, name = nil)
        @ticket, @name = ticket, name.to_s
      end
    end
  end
end
