module Me
  module View
    def self.new(*args)
      return super if args[0].is_a?(Hash)
      Class.new(Struct.new(*args)) do
        include View
      end
    end

    def initialize(hash)
      super()
      hash.each { |k, v| self[k] = v }
    end
  end
end
