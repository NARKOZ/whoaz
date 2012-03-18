require 'whoaz/version'
require 'whoaz/core_ext/object'
require 'whoaz/core_ext/string'
require 'whoaz/whois'
require 'whoaz/errors'
require 'net/http'
require 'nokogiri'

module Whoaz
  WHOIS_URL     = 'http://nic.az/cgi-bin/whois.cgi'
  WHOIS_REFERER = 'http://nic.az' # The URL to the WHOIS server. It's the same as <tt>http://whois.az</tt>.
  MAIN_TLD      = %w(az biz.az co.az com.az edu.az gov.az info.az int.az mil.az name.az net.az org.az pp.az pro.az)
  REGIONAL_TLD  = %w(bilesuvar.az ganja.az imishli.az samux.az shamaxi.az shusha.az sumgait.az zaqatala.az)

  # Creates a new Whois object.
  #
  # @param  [String] domain The domain name required to query.
  # @return [Whoaz::Whois]
  def self.whois(domain='')
    domain = domain.to_s.strip.downcase
    raise EmptyDomain, "Domain name is not specified" if domain.empty?
    raise InvalidDomain, "Domain name contains non-ASCII characters" unless domain.ascii_only?
    Whoaz::Whois.new(domain)
  end
end
