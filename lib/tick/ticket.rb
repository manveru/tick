module Tick
  Ticket = Struct.new(*COMMON_MEMBERS, :name, :status, :descriptions, :tags, :author)

  # Tickets contain issue descriptions.
  #
  # Tickets have:
  #
  # * parent (Milestone)
  # * created_at
  # * updated_at
  # * name
  # * status
  # * description
  # * tags
  # * author
  class Ticket
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    alias milestone parent

    def generate_path
      parent.path/"tickets/Ticket-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Ticket' do |store|
        milestone_tree = store.tree(parent.path)
        tickets_tree = milestone_tree.tree('tickets')
        ticket_tree = tickets_tree.tree(path.basename)

        dump_into(ticket_tree)
      end

      self
    end
  end
end
