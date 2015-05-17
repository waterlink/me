require "me/registry"

module Me
  class Activation
    def build_view(view_factory)
      view_factory.new(commands: commands)
    end

    def call
      fail
    end

    def ==(other)
      return false unless other.is_a?(Activation)
      self.commands == other.commands
    end

    def _with_commands(commands)
      @_commands = commands
      self
    end

    protected

    def commands
      @_commands ||= []
    end

    private

    def execute
      commands.each(&executor.method(:call))
    end

    def executor
      @_executor ||= Registry.executor_factory.new
    end
  end
end
