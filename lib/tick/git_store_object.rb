module Tick
  module GitStoreObject
    TYPES = {
      :created_at => :time,
      :updated_at => :time,
      :tags => :set,
    }

    TYPES.default = :string

    def to_hash
      hash = Hash[members.map{|member| [member, self[member]] }]
      hash.delete_if{|k,v| TYPES[k] == :skip }
      hash
    end

    def sha1
      Digest::SHA1.hexdigest(to_hash.inspect)
    end

    def dump(type, member)
      case type
      when :string; {member => self[member].to_s}.to_json
      when :date;   {member => self[member].to_s}.to_json
      when :time;   {member => self[member].to_i}.to_json
      when :set;    [*self[member]].uniq.sort.to_json
      else
        raise("Unknown type for %p: %p" % [member, type])
      end
    end

    def parse(json, type, member)
      case type
      when :string; JSON.parse(json)[member.to_s]
      when :date;   Date.parse(JSON.parse(json)[member.to_s])
      when :time;   Time.at(JSON.parse(json)[member.to_s])
      when :set;    Set.new(JSON.parse(json))
      else
        raise("Unknown type for %p: %p" % [member, type])
      end
    end
  end
end
