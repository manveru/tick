module Tick
  COMMON_MEMBERS = [:parent, :created_at, :updated_at]

  # This module contains the methods used by all our so-called git store objects.
  # The classes using them will have to implement the `#save` and
  # `#generate_path` methods in order for this to work.
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

      def update(hash = {})
        hash.each{|key, value| self[key] = value }
        save
      end

      def inspect
        to_hash.inspect
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
        when :string; {member => self[member].to_s}
        when :time;   {member => self[member].to_i}
        when :set;    [*self[member]].uniq.sort
        else
          raise("Unknown type for %p: %p" % [member, type])
        end
      end

      def parse(json, type, member)
        # p :parse => [json, type, member]
        case type
        when :string; json[member.to_s]
        when :time;   Time.at(json[member.to_s])
        when :set;    Set.new(json)
        else
          raise("Unknown type for %p: %p" % [member, type])
        end
      end

      def tree(*args)
        parent.tree(*args)
      end

      def transaction(message)
        store = parent.store
        store.transaction(message){ yield(store) }
      rescue => ex
        puts ex, *ex.backtrace
      ensure
        store.refresh!
      end

      def store
        parent.store
      end

      def dump_into(tree)
        types = self.class::TYPES

        self.class.members.each do |member|
          type = types[member]
          next if type == :skip

          tree[member] = dump(type, member)
        end
      end
    end
  end
end
