require "me/activation"
require "me/registry"

module Me
  class SshActivation < Activation
    def initialize(keys)
      @keys = keys
    end

    def call
      clear_ssh_keys
      keys.each(&method(:add_ssh_key))
      execute
    end

    protected

    attr_reader :keys

    def clear_ssh_keys
      commands << ["ssh-add", "-D"]
    end

    def add_ssh_key(key)
      commands << ["ssh-add", key]
    end
  end
end
