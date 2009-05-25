require 'date'

module Tick
  Milestone = Struct.new(:repo, :name, :status, :description, :created_at,
                         :updated_at)

  # Milestone is a named collection of tickets
  class Milestone
    include GitStoreObject
    TYPES[:repo] = :skip

    def self.create(repo, properties = {})
      properties[:repo] = repo
      values = properties.values_at(*members)
      instance = new(*values)
      instance.save
      instance
    end

    def self.open(repo, path)
      tree = repo.store.tree(path)
      instance = new(repo)

      members.each do |member|
        type = TYPES[member]
        instance[member] = instance.parse(tree[member.to_s], type, member)
      end

      instance
    end

    attr_reader :path

    def initialize(*args)
      super

      self.created_at ||= Time.now
      self.updated_at ||= Time.now
      @path = Tick::Pathname("Milestone-#{sha1}")
    end

    def tickets
      milestone_tree = repo.store.tree(path)
      tickets_tree = milestone_tree.tree(:tickets)
      tickets_path = path/:tickets

      tickets_tree.table.keys.map do |key|
        Ticket.open(self, tickets_path/key)
      end
    end

    def create_ticket(*args)
      Ticket.create(self, *args)
    end

    def <=>(milestone)
      return 1 if name == 'future'
      return -1 if milestone.name == 'future'
      super
    end

    def save
      self.updated_at = Time.now
      path = self.path

      transaction 'Updating Milestone' do |store|
        tree = store.tree(path)

        self.class.members.each do |member|
          type = TYPES[member]
          next if type == :skip

          tree[member] = dump(type, member)
        end
      end
    end

    def transaction(message)
      store = repo.store
      store.transaction(message){ yield(store) }
    ensure
      store.refresh!
    end
  end
end
