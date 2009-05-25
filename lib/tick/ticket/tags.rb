module Tick
  class Ticket
    class Tags
      Ticket::PROPERTIES['tags'] = self

      def self.dump(obj)
        JSON.pretty_unparse([*obj].flatten.uniq.sort)
      end

      def initialize(ticket, tags = [])
        @ticket, @tags = ticket, Set.new(tags.flatten)
      end
    end
  end
end
