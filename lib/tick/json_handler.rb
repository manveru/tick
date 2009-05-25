module Tick
  class JSONHandler
    def read(data)
      JSON.parse(data)
    end

    def write(data)
      JSON.pretty_unparse(data)
    end
  end
end
