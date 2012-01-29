module Whoaz
  class Error < StandardError; end
  class EmptyDomain < Error; end
  class InvalidDomain < Error; end
  class ServerError < Error; end
  class DomainNameError < Error; end
end
