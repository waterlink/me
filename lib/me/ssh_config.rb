require "me/registry"

module Me
  class SshConfig
    def initialize(keys, identity_name)
      @keys = keys
      @identity_name = identity_name
    end

    def ==(other)
      return false unless other.is_a?(SshConfig)
      self.keys == other.keys
    end

    def configure
      return if keys.empty?
      store.save_ssh_config("keys" => keys)
    end

    def build_view(view_factory)
      view_factory.new(keys: keys)
    end

    def _load
      @keys = store.ssh_config["keys"]
      self
    end

    protected

    attr_reader :keys, :identity_name

    def store
      @_store ||= Registry.store_factory.with_identity(identity_name)
    end
  end

  class << SshConfig
    def for_identity(identity_name)
      new(nil, identity_name)._load
    end
  end
end
