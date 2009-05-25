module Tick
  Comment = Struct.new(*COMMON_MEMBERS, :author, :content)

  class Comment
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    alias ticket parent

    def generate_path
      @path = parent.path/"comments/Comment-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Comment' do |store|
        ticket_tree = store.tree(parent.path)
        comments_tree = ticket_tree.tree(:comments)
        comment_tree = comments_tree.tree(path.basename)

        dump_into(comment_tree)
      end

      self
    end
  end
end
