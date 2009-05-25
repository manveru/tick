module Tick
  Ticket = Struct.new(:parent, :name, :status, :description, :created_at,
                      :updated_at, :tags, :author)

  # Tickets contain issue descriptions
  class Ticket
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    PATH_PREFIX = "tickets/Ticket-"

    alias milestone parent

    def generate_path
      parent.path/"#{PATH_PREFIX}#{sha1}"
    end

    def update(hash = {})
      hash.each{|key, value| self[key] = value }
      save
    end

    def inspect
      to_hash.inspect
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Ticket' do |store|
        milestone_tree = store.tree(parent.path)
        tickets_tree = milestone_tree.tree('tickets')
        ticket_tree = tickets_tree.tree(path.basename)

        self.class.members.each do |member|
          type = TYPES[member]
          next if type == :skip

          ticket_tree[member] = dump(type, member)
        end
      end

      self
    end
  end
end
