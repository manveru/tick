require 'bacon'
Bacon.summary_at_exit

require File.expand_path('../../lib/tick', __FILE__)

shared :tick do
  def tick(path = 'temp_spec', branch = 'spec')
    @path, @branch = Pathname(path).expand_path, branch

    unless defined?(@tick)
      FileUtils.rm_rf(@path)
      Tick.git_init(@path, 'tick spec init')
      @tick = Tick.open(@path, @branch)
    end

    @tick
  end
end
