require 'optparse'

module Tick
  class Bin
    attr_reader :args, :op, :options, :command
    attr_accessor :window_lines, :window_cols

    def initialize(args)
      @args = args
      @op = OptionParser.new
      @options = {:repo => './', :branch => 'tick'}
      @repo = nil

      determine_window_dimensions
    end

    def repo
      path, branch = options[:repo], options[:branch]
      @repo ||= Tick.open(path, branch)
    end

    def run
      global_parser

      load_command(args.first) do |cmd|
        @command = args.shift

        if cmd.respond_to?(:parser)
          op.new
          cmd.parser(self, options)
          op.top.prepend 'Command options:', nil, nil
          op.top.prepend '', nil, nil
        end

        op.parse!(args)
        cmd.run(self, options) if cmd.respond_to?(:run)
      end

      run_fallback
    end

    def run_fallback
      op.parse!(args)
      puts op
      exit 1
    end

    def global_parser
      op.program_name = 'tick'
      op.version = VERSION
      op.release = 'Copyright 2009 by The Rubyists LLC.'

      op.separator ''
      op.separator 'General options:'
      op.on('--repo PATH', 'Path to repository'){|v| options[:repo] = v }
      op.on('--branch NAME', 'Branch in repo'){|v| options[:branch] = v }
      op.on('-h', '--help', 'Show this help'){ puts op; exit }
      op.on('-v', '--version', 'Show the version'){ puts op.ver; exit }
    end

    # Shortcuts to OptionParser instance

    def option(name, description, &block)
      name = name.to_s
      block ||= lambda{|v| options[name.to_sym] = v }
      short, long = "-#{name[0,1]}", "--#{name}"
      op.on_head(name, description, &block)
    end

    def on(*args, &block)
      op.on(*args, &block)
    end

    def on_tail(*args, &block)
      op.on_tail(*args, &block)
    end

    def on_head(*args, &block)
      op.on_head(*args, &block)
    end

    # Command over commands

    def load_command(name)
      require "tick/bin/#{name}"
      const = self.class.const_get(name.capitalize)
      block_given? ? yield(const) : const
    rescue LoadError
    end

    def commands
      glob = File.expand_path('../bin/*.rb', __FILE__)
      Dir[glob].map{|f| File.basename(f, '.rb') }
    end

    # Determining window width

    TIOCGWINSZ_INTEL = 0x5413     # For an Intel processor
    TIOCGWINSZ_PPC   = 0x40087468 # For a PowerPC processor
    STDOUT_HANDLE    = 0xFFFFFFF5 # For windows

    def determine_window_dimensions
      lines, cols = try_intel || try_ppc || try_windows || use_fallback
      self.window_lines, self.window_cols = lines, cols
    end

    def try_ppc
      try_using(TIOCGWINSZ_PPC)
    end

    def try_intel
      try_using(TIOCGWINSZ_INTEL)
    end

    # Set terminal dimensions using ioctl syscall on *nix platform
    # TODO: find out what is being raised here on windows.
    def try_using(mask)
      buf = [0,0,0,0].pack("S*")
      return unless $stdout.ioctl(mask, buf) >= 0
      buf.unpack("S2")
    rescue Errno::EINVAL # wrong platform
    end

    # Determine terminal dimensions on windows platform
    def try_windows
      m_GetStdHandle =
        Win32API.new('kernel32', 'GetStdHandle', ['L'], 'L')
      m_GetConsoleScreenBufferInfo =
        Win32API.new('kernel32', 'GetConsoleScreenBufferInfo', ['L', 'P'], 'L')
      format = 'SSSSSssssSS'
      buf = ([0] * format.size).pack(format)
      stdout_handle = m_GetStdHandle.call(STDOUT_HANDLE)

      m_GetConsoleScreenBufferInfo.call(stdout_handle, buf)

      (bufx, bufy, curx, cury, wattr,
       left, top, right, bottom, maxx, maxy) = buf.unpack(format)

      return bottom - top + 1, right - left + 1
    rescue NameError # No Win32API
    end

    def use_fallback
      return 25, 80
    end
  end
end
