module Tick
  Milestone = Struct.new(*COMMON_MEMBERS, :name, :status, :description)

  # Milestone is a named collection of tickets
  class Milestone
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    alias repo parent

    def generate_path
      self.path = Tick::Pathname("Milestone-#{sha1}")
    end

    # This should be lazier...
    def tickets
      subtree_map(Ticket, :tickets)
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

      transaction 'Updating Milestone' do |store|
        dump_into(tree(path.to_s))
      end

      self
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
