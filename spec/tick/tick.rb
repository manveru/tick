require 'spec/helper'

describe 'Tick' do
  describe 'setup' do
    @path = File.expand_path('temp_spec')
    @branch = 'spec'

    FileUtils.mkdir_p(@path)

    it 'complains if the the target path is no git repo' do
      lambda{
        Tick::Repo.new(@path, @branch)
      }.should.raise(ArgumentError).message.
        should == "first argument must be a valid Git repository: `#@path'"
    end

    Dir.chdir(@path){
      system('git', 'init')
      File.open('VERSION', 'w+'){|io| io.write('2009.05.15') }
      system('git', 'add', '.')
      system('git', 'commit', '-m', 'init')
    }

    it 'creates a branch when it is missing' do
      @repo = Tick::Repo.new(@path, @branch)
      @repo.path.should == @path
      @repo.branch.should == @branch
    end

    it 'shows a list of all tickets that is empty' do
      @repo.tickets.should == []
    end

    it 'creates a ticket' do
      @ticket = Tick::Ticket.new(:title => 'just testing')
      @ticket.title.should == 'just testing'
    end

    it 'stores the ticket and it shows up in the ticket list' do
      @repo << @ticket
      @repo.tickets.should == [@ticket]
    end

    it 'does not show up in another Repo instance yet' do
      repo = Tick::Repo.new(@path, @branch)
      repo.tickets.should == []
    end

    it 'commits the changes' do
      commit = @repo.commit('added first ticket')
      commit.message.should == 'added first ticket'
    end

    it 'still shows a list of all tickets with our ticket' do
      @repo.tickets.should == [@ticket]
    end

    it 'also shows up in another Repo instance' do
      repo = Tick::Repo.new(@path, @branch)
      repo.tickets.should == [@ticket]
    end

    it 'stores a more sophisticated ticket' do
      due_time = Time.now + 100_000

      ticket = Tick::Ticket.new(
        :title => 'implement comments',
        :text => 'some text',
        :due => due_time,
        :open => false
      )

      @repo << ticket
      first = @repo.tickets.first
      # first.should == ticket
      first.class.members.each do |member|
        first[member].should == ticket[member]
      end
    end

    FileUtils.rm_r(@path)
  end
end
