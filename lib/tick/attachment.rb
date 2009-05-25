module Tick
  Attachment = Struct.new(*COMMON_MEMBERS, :author, :content)

  class Attachment
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    alias ticket parent

    def generate_path
      @path = parent.path/"attachments/Attachment-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Attachment' do |store|
        ticket_tree = store.tree(parent.path)
        attachments_tree = ticket_tree.tree(:attachments)
        attachment_tree = attachments_tree.tree(path.basename)

        dump_into(attachment_tree)
      end

      self
    end
  end
end
