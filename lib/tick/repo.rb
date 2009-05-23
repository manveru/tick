module Tick
  class Repo
    attr_reader :path, :branch, :store

    def initialize(path, branch = 'tick')
      @path, @branch = path, branch
      @store = GitStore.new(path, branch)
      @store.refresh! # make sure we have latest data
      @store.handler['tick'] = TicketHandler.new
    end

    def tickets
      all = []

      if tree = @store['tickets']
        @store['tickets'].each{|file, ticket| all << ticket }
      end

      all
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
