module Me
  # Represents piece of personalised git configuration
  class GitConfig
    def initialize(name, email, identity_name)
      @name = name
      @email = email
      @identity_name = identity_name
    end

    def ==(other)
      return false unless other.is_a?(GitConfig)
      self.equality_fields == other.equality_fields
    end

    def configure
      return unless name && email
      store.save_git_config("name" => name, "email" => email)
    end

    def build_view(view_factory)
      view_factory.new(name: name, email: email)
    end

    # @api private
    def _load
      @name = store.git_config["name"]
      @email = store.git_config["email"]
      self
    end

    protected

    attr_reader :name, :email, :identity_name

    def equality_fields
      [name, email]
    end

    def store
      @_store ||= Registry.store_factory.with_identity(identity_name)
    end
  end

  class << GitConfig
    def for_identity(identity_name)
      GitConfig.new(nil, nil, identity_name)._load
    end
  end
end
