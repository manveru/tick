module Tick
  class Repo
    attr_reader :path, :branch, :store

    def initialize(path, branch = 'tick')
      @path, @branch = path, branch
      @store = GitStore.new(path.to_s, branch)
      @store.refresh! # make sure we have latest data
      # @store.handler['tick'] = TicketHandler.new
    end

    def sanitize!
      # make sure we have a future milestone
      milestone = Milestone.new(:name => 'future')
      FileUtils.mkdir_p(File.join(path, 'future'))
    end

    def milestones
      store.root.table.keys.map do |key|
        Milestone.open(self, key)
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
  end
end
