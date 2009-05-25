module Tick
  # Some extensions for Pathname, keeping it in Tick module for squeaky clean
  # code.
  class Pathname < ::Pathname
    def /(other)
      join(other.to_s)
    end

    def mkdir_p
      FileUtils.mkdir_p(to_s)
    end

    #
    # Pathname#join joins pathnames.
    #
    # <tt>path0.join(path1, ..., pathN)</tt> is the same as
    # <tt>path0 + path1 + ... + pathN</tt>.
    #
    def join(*args)
      args.unshift self
      result = args.pop
      result = self.class.new(result) unless ::Pathname === result
      return result if result.absolute?
      args.reverse_each {|arg|
        arg = self.class.new(arg) unless ::Pathname === arg
        result = arg + result
        return result if result.absolute?
      }
      result
    end

    #
    # Pathname#+ appends a pathname fragment to this one to produce a new Pathname
    # object.
    #
    #   p1 = Pathname.new("/usr")      # Pathname:/usr
    #   p2 = p1 + "bin/ruby"           # Pathname:/usr/bin/ruby
    #   p3 = p1 + "/etc/passwd"        # Pathname:/etc/passwd
    #
    # This method doesn't access the file system; it is pure string manipulation.
    #
    def +(other)
      other = self.class.new(other) unless ::Pathname === other
      self.class.new(plus(@path, other.to_s))
    end

    #
    # #relative_path_from returns a relative path from the argument to the
    # receiver.  If +self+ is absolute, the argument must be absolute too.  If
    # +self+ is relative, the argument must be relative too.
    #
    # #relative_path_from doesn't access the filesystem.  It assumes no symlinks.
    #
    # ArgumentError is raised when it cannot find a relative path.
    #
    # This method has existed since 1.8.1.
    #
    # SIGH: When will people learn to use self.class.new to allow subclassing?
    def relative_path_from(base_directory)
      dest_directory = self.cleanpath.to_s
      base_directory = base_directory.cleanpath.to_s
      dest_prefix = dest_directory
      dest_names = []

      while r = chop_basename(dest_prefix)
        dest_prefix, basename = r
        dest_names.unshift basename if basename != '.'
      end

      base_prefix = base_directory
      base_names = []

      while r = chop_basename(base_prefix)
        base_prefix, basename = r
        base_names.unshift basename if basename != '.'
      end

      unless SAME_PATHS[dest_prefix, base_prefix]
        raise ArgumentError, "different prefix: #{dest_prefix.inspect} and #{base_directory.inspect}"
      end

      while !dest_names.empty? &&
            !base_names.empty? &&
            SAME_PATHS[dest_names.first, base_names.first]
        dest_names.shift
        base_names.shift
      end

      if base_names.include? '..'
        raise ArgumentError, "base_directory has ..: #{base_directory.inspect}"
      end

      base_names.fill('..')
      relpath_names = base_names + dest_names

      if relpath_names.empty?
        self.class.new('.')
      else
        self.class.new(File.join(*relpath_names))
      end
    end
  end
end
