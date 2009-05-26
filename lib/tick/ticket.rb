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
      self.path = parent.path/"tickets/Ticket-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Ticket' do |store|
        dump_into(object_tree('tickets'))
      end

      self
    end

    def comments
      subtree_map(Comment, :comments)
    end

    def create_comment(*args)
      Comment.create(self, *args)
    end

    def attachments
      subtree_map(Attachment, :attachments)
    end

    def create_attachment(*args)
      Attachment.create(self, *args)
    end
  end
end
