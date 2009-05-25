module Tick
  Ticket = Struct.new(:milestone, :name, :status, :description, :created_at,
                      :updated_at, :tags, :author)

  class Ticket
    include GitStoreObject
    TYPES[:milestone] = :skip

    def self.create(milestone, properties = {})
      properties = properties.merge(:milestone => milestone)
      values = properties.values_at(*members)
      instance = new(*values)
      instance.save
      instance
    end

    def self.open(milestone, path)
      tree = milestone.repo.store
      instance = new(milestone)

      members.each do |member|
        type = TYPES[member]
        next if type == :skip

        value = tree[path/member]
        instance[member] = instance.parse(value, type, member)
      end

      instance
    end

    attr_reader :path

    def initialize(*args)
      super

      self.created_at ||= Time.now
      @path = milestone.path/"tickets/Ticket-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      milestone.transaction 'Updating Ticket' do |store|
        milestone_tree = store.tree(milestone.path)
        tickets_tree = milestone_tree.tree('tickets')
        ticket_tree = tickets_tree.tree(path.basename)

        self.class.members.each do |member|
          type = TYPES[member]
          next if type == :skip

          ticket_tree[member] = dump(type, member)
        end
      end
    end
  end
end
