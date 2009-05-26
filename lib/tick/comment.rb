module Tick
  Comment = Struct.new(*COMMON_MEMBERS, :author, :content)

  class Comment
    include GitStoreObject::InstanceMethods
    extend GitStoreObject::SingletoneMethods

    alias ticket parent

    def generate_path
      self.path = parent.path/"comments/Comment-#{sha1}"
    end

    def save
      self.updated_at = Time.now

      parent.transaction 'Updating Comment' do |store|
        dump_into(object_tree('comments'))
      end

      self
    end
  end
end
