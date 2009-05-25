module Tick
  module GitStoreObject
    module SingletoneMethods
      def create(parent, properties = {})
        properties = properties.merge(parent: parent)
        values = properties.values_at(*members)
        instance = new(*values)
        instance.save
        instance
      end

      def from(parent, hash)
        instance = new(parent)
        types = instance.class::TYPES

        members.each do |member|
          type = types[member]
          next if type == :skip

          value = hash[member.to_s]
          instance[member] = instance.parse(value, type, member)
        end

        instance
      end
    end

    module InstanceMethods
      TYPES = {
        :created_at => :time,
        :updated_at => :time,
        :tags => :set,
        :parent => :skip,
      }

      TYPES.default = :string

      attr_reader :path, :parent

      def initialize(*args)
        super

        self.created_at ||= Time.now
        self.updated_at ||= Time.now

        @path = generate_path
      end

      def to_hash
        hash = Hash[members.map{|member| [member, self[member]] }]
        hash.delete_if{|k,v| TYPES[k] == :skip }
        hash
      end

      def sha1
        Digest::SHA1.hexdigest(to_hash.inspect)
      end

      def dump(type, member)
        # p :dump => [type, member]
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
        # p :parse => [json, type, member]
        case type
        when :string; JSON.parse(json)[member.to_s]
        when :date;   Date.parse(JSON.parse(json)[member.to_s])
        when :time;   Time.at(JSON.parse(json)[member.to_s])
        when :set;    Set.new(JSON.parse(json))
        else
          raise("Unknown type for %p: %p" % [member, type])
        end
      end

      def tree(*args)
        parent.tree(*args)
      end
    end
  end
end
