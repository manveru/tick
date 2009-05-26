module Tick
  class Repo
    attr_reader :path, :branch, :store

    def initialize(path, branch = 'tick', bare = false)
      @path, @branch = path, branch
      @store = GitStore.new(path.to_s, branch, bare)
      @store.handler.default = JSONHandler.new
      @store.refresh! # make sure we have latest data
    end

    def sanitize!
      # make sure we have a future milestone
      Milestone.create(self, :name => 'future')
    end

    # The milestone that was last updated.
    # If none was here yet, we create the future milestone.
    def milestone
      milestones.sort_by{|m| m.updated_at }.last || sanitize!
    end

    def milestones
      store.root.table.map do |key, value|
        Milestone.from(self, Tick::Pathname(key), value)
      end
    end

    def create_milestone(*args)
      Milestone.create(self, *args)
    end

    def <<(ticket)
      @store["tickets/#{ticket.file}"] = ticket
    end

    def commit(message)
      @store.commit(message)
    ensure
      @store.refresh!
    end

    def tree(*args)
      store.tree(*args)
    end
  end
end
