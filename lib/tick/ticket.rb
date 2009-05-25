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

    TYPES[:tags] = :set

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

    def comments
      ticket_tree = tree(path)
      comments_tree = ticket_tree.tree(:comments)
      comments_path = path/:comments

      comments_tree.table.map do |key, value|
        Comment.from(self, value)
      end
    end

    def create_comment(*args)
      Comment.create(self, *args)
    end

    def attachments
      ticket_tree = tree(path)
      attachments_tree = ticket_tree.tree(:attachments)
      attachments_path = path/:attachments

      attachments_tree.table.map do |key, value|
        Attachment.from(self, value)
      end
    end

    def create_attachment(*args)
      Attachment.create(self, *args)
    end
  end
end
