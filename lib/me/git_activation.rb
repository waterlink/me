require "me/activation"

module Me
  class GitActivation < Activation
    def initialize(name, email)
      @name = name
      @email = email
    end

    def call
      activate_name
      activate_email
      execute
    end

    protected

    attr_reader :name, :email

    private

    def activate_name
      commands << ["git", "config", "--global", "user.name", name]
    end

    def activate_email
      commands << ["git", "config", "--global", "user.email", email]
    end
  end
end
