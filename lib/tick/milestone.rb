module Tick
  Milestone = Struct.new(:parent, :name, :status, :description, :created_at,
                         :updated_at)

  # Milestone is a named collection of tickets
  class Milestone
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    PATH_PREFIX = "Milestone-"

    alias repo parent

    def generate_path
      Tick::Pathname("#{PATH_PREFIX}#{sha1}")
    end

    # This should be lazier...
    def tickets
      milestone_tree = tree(path)
      tickets_tree = milestone_tree.tree(:tickets)
      tickets_path = path/:tickets

      tickets_tree.table.map do |key, value|
        Ticket.from(self, value)
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
        tree = tree(path)

        self.class.members.each do |member|
          type = TYPES[member]
          next if type == :skip

          tree[member] = dump(type, member)
        end
      end
    end

    def transaction(message)
      store = parent.store
      store.transaction(message){ yield(store) }
    ensure
      store.refresh!
    end

    # select tickets that match all of the criteria given
    # if a block is given, it will be used for selection instead.
    def select(criteria = {}, &block)
      if block_given?
        tickets.select(&block)
      else
        tickets.select do |ticket|
          criteria.all? do |key, value|
            ticket[key] == value
          end
        end
      end
    end
  end
end
