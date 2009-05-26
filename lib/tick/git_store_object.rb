module Tick
  COMMON_MEMBERS = [:parent, :path, :created_at, :updated_at]

  # This module contains the methods used by all our so-called git store objects.
  # The classes using them will have to implement the `#save` and
  # `#generate_path` methods in order for this to work.
  module GitStoreObject
    module SingletoneMethods
      def create(parent, properties = {})
        properties = properties.merge(parent: parent)
        values = properties.values_at(*members)
        instance = new(*values)
        instance.generate_path
        instance.save
        instance
      end

      def from(parent, path, hash)
        instance = new(parent, path)
        types = instance.class::TYPES

        members.each do |member|
          type = types[member]
          next if type == :skip

          value = hash[member.to_s]
          next if value.nil?
          instance[member] = instance.parse(value, type, member)
        end

        instance
      end
    end

    module InstanceMethods
      TYPES = {
        :created_at => :time,
        :updated_at => :time,
        :path => :skip,
        :parent => :skip,
      }

      TYPES.default = :string

      def initialize(*args)
        super

        self.created_at ||= Time.at(Time.now.to_i) # roundtrip to chop off
        self.updated_at ||= Time.at(Time.now.to_i) # roundtrip to chop off
      end

      def generate_path
        @path = super
      end

      def update(hash = {})
        changes = false

        self.class.members.each do |member|
          value = hash[member.to_sym] || hash[member.to_s]
          next if value.nil? or self[member] == value
          changes = true
          self[member] = value
        end

        save if changes
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
        id = (self.class.members - COMMON_MEMBERS).map{|member| self[member] }
        Digest::SHA1.hexdigest(id.inspect)
      end

      def tick_id
        path.basename.to_s.split('-').last[0..6]
      end

      def tick_name
        "#{name} (#{tick_id})"
      end

      def dump(value, type, member)
        case type
        when :string; {member => value.to_s}
        when :time;   {member => value.to_i}
        when :set;    [*value].uniq.sort
        else
          raise("Unknown type for %p: %p" % [member, type])
        end
      end

      def parse(json, type, member)
        case type
        when :string; json[member.to_s]
        when :time;   Time.at(json[member.to_s])
        when :set;    [*json].flatten.uniq.sort
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

          value = self[member]
          next if value.nil?

          tree[member] = dump(value, type, member)
        end
      end
    end
  end
end
