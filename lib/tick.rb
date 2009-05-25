# stdlib
require 'date'
require 'json'
require 'pathname'
require 'pp'
require 'set'
require 'time'

# 3rd party
require 'git_store'

$:.unshift(File.dirname(__FILE__))

module Tick
  autoload :Milestone,      'tick/milestone'
  autoload :Pathname,       'tick/pathname'
  autoload :Repo,           'tick/repo'
  autoload :Ticket,         'tick/ticket'
  autoload :TicketHandler,  'tick/ticket_handler'
  autoload :GitStoreObject, 'tick/git_store_object'

  module_function

  # TODO: create repo without relying on git?
  def git_init(path, message = 'tick init')
    path = path.to_s
    FileUtils.mkdir_p(path)

    Dir.chdir path do
      system('git', 'init') || return
      File.open('.tick', 'w+'){|io| io.write(Date.today.to_s) }
      system('git', 'add', '.tick')
      system('git', 'commit', '-m', message.to_s)
    end
  end

  def open(path, branch)
    Repo.new(path, branch)
  end

  def Pathname(path)
    Tick::Pathname.new(path.to_s)
  end
end
