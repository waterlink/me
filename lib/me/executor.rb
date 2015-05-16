require "me/registry"

module Me
  class Executor
    def call(command)
      kernel.system(*command)
    end

    private

    def kernel
      Registry.kernel
    end
  end
end
