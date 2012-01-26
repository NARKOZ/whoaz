require 'whoaz/version'
require 'whoaz/ruby_ext'
require 'whoaz/whois'
require 'whoaz/errors'
require 'net/http'
require 'nokogiri'

module Whoaz
  WHOIS_URL     = 'http://nic.az/cgi-bin/whois.cgi'
  WHOIS_REFERER = 'http://nic.az'
  MAIN_TLD      = %w(az biz.az co.az com.az edu.az gov.az info.az int.az mil.az name.az net.az org.az pp.az)
  REGIONAL_TLD  = %w(bilesuvar.az ganja.az imishli.az samux.az shamaxi.az shusha.az sumgait.az zaqatala.az)

  def self.whois(domain='')
    domain = domain.to_s.strip.downcase
    raise EmptyDomain, "Domain not specified" if domain.empty?
    Whoaz::Whois.new(domain)
  end
end
