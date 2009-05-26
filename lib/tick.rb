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
  def git_init(path)
    ENV['GIT_DIR'] = path.to_s
    system('git', 'init', '--bare', '--quiet') || return
  end

  def open(path, branch, bare = false)
    Repo.new(path, branch, bare)
  end
  alias Repo open

  def Pathname(path)
    Tick::Pathname.new(path.to_s)
  end
end

# apply some fixes to work on 1.9
class GitStore
  if 'String'.respond_to?(:ord)
    def legacy_loose_object?(buf)
      word = (buf[0].ord << 8) + buf[1].ord

      buf[0] == ?x && word % 31 == 0
    end
  else
    def legacy_loose_object?(buf)
      word = (buf[0] << 8) + buf[1]

      buf[0] == ?x && word % 31 == 0
    end
  end
end
