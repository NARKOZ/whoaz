module Whoaz
  # Custom error class for rescuing from all Whoaz errors.
  class Error < StandardError; end

  # Raised when domain name is not passed.
  class EmptyDomain < Error; end

  # Raised when invalid domain name is passed.
  class InvalidDomain < Error; end

  # Raised when WHOIS server doesn't return the HTTP status code 200 (OK).
  class ServerError < Error; end
end
