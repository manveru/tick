module Tick::Bin::Help
  DESCRIPTION = 'Display help information about tick'
  USAGE = <<-DOC
tick help displays help information about tick

SYNOPSIS
  tick help [COMMAND]

DESCRIPTION
  With no options and no COMMAND given, the synopsis of the tick command and a
  list of tick commands are printed on the standard output.

  If a tick command is named, usage information for that command is shown if
  available.
  DOC

  module_function

  def run(bin, options)
    if cmd = bin.args.first
      about(bin, cmd)
    else
      list_commands(bin)
    end

    exit
  end

  def list_commands(bin)
    puts "\nThe available tick commands are:"

    bin.commands.each do |cmd|
      puts("#{cmd}\t#{description_of(bin, cmd)}")
    end

    puts
    puts "See 'tick help COMMAND' for more information on a specific command"
  end

  def about(bin, command)
    bin.load_command(command) do |mod|
      puts mod::USAGE
    end
  rescue NameError => ex
    if ex.message =~ /uninitialized constant .*::USAGE$/
      puts "No help available for '#{command}'"
    else
      raise ex
    end
  end

  def description_of(bin, command)
    bin.load_command(command) do |mod|
      mod::DESCRIPTION
    end
  rescue NameError
    ''
  end
end
