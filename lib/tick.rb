# stdlib
require 'date'
require 'json'
require 'pathname'
require 'pp'
require 'set'
require 'time'
require 'tmpdir'

# 3rd party
require 'git_store'

$:.unshift(File.dirname(__FILE__))

require 'tick/git_store_object'
require 'tick/pathname'
require 'tick/json_handler'
require 'tick/repo'
require 'tick/milestone'
require 'tick/ticket'

module Tick
  autoload :VERSION, 'tick/version'
  autoload :Comment, 'tick/comment'
  autoload :Attachment, 'tick/attachment'

  module_function

  # TODO: create repo without relying on git?
  def git_init(path, message = 'tick init')
    ENV['GIT_DIR'] = path.to_s
    system('git', 'init', '--bare', '--quiet') || return
  end

  def open(path, branch)
    Repo.new(path, branch)
  end

  def Pathname(path)
    Tick::Pathname.new(path.to_s)
  end
end
