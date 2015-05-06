module Me
  module Errors
    class Base < RuntimeError; end
    class GitNotConfigured < Base; end
    class SshNotConfigured < Base; end
    class NoActiveIdentity < Base; end
  end
end
