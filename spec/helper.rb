require 'bacon'
Bacon.summary_at_exit

require File.expand_path('../../lib/tick', __FILE__)

shared :tick do
  def tick(path = 'temp_spec', branch = 'spec')
    @branch = branch
    @path = path = Tick::Pathname.tmpdir/"#{path}.#{rand}"

    unless defined?(@tick)
      Tick.git_init(@path)
      # use the local variable or we will only delete the most recent
      at_exit{ path.rm_rf }
      @tick = Tick.open(@path, @branch, bare = true)
    end

    @tick
  end
end
