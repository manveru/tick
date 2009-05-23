# stdlib
require 'pathname'
require 'time'
require 'date'
require 'json'
require 'pp'

# 3rd party
require 'git_store'

dir = Pathname(__FILE__).parent
unless $LOAD_PATH.include?(dir.to_s) or $LOAD_PATH.include?(dir.expand_path.to_s)
  $LOAD_PATH.unshift(dir.expand_path.to_s)
end

require 'tick/ticket'
require 'tick/repo'
require 'tick/json_handler'
