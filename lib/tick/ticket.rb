module Tick
  TICKET_MEMBERS = [:title, :text, :due, :open]

  class Ticket < Struct.new(*TICKET_MEMBERS.map{|m| m.to_sym })
    def initialize(hash = {})
      TICKET_MEMBERS.each do |key|
        unless hash.key?(key)
          key = key.to_s
          next unless hash.key?(key)
        end

        value = hash[key]

        case key
        when :due, 'due'
          send("#{key}=", Time.at(value))
        else
          self[key] = value
        end
      end
    end

    def file
      title.to_s.sub(/[^\w]/, '_') << '.tick'
    end

    # Ruby stores time as float, we don't need that precision.
    def due=(time)
      self[:due] = Time.at(time.to_i)
    end

    def to_json
      hash = {}

      TICKET_MEMBERS.each do |key|
        value = self[key]

        case key
        when :due
          hash[key] = value.to_i if value
        else
          hash[key] = value
        end
      end

      JSON.pretty_generate( :ticket => Hash[hash] )
    end
  end
end
