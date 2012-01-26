module Whoaz
  class Whois
    attr_accessor :name, :organization, :address, :phone, :fax, :email, :nameservers
    attr_accessor :free

    def initialize(domain)
      post_domain = domain.split('.', 2)
      raise InvalidDomain, "Invalid domain specified" unless
        MAIN_TLD.include?(post_domain.last) || REGIONAL_TLD.include?(post_domain.last)

      url = URI WHOIS_URL
      req = Net::HTTP::Post.new(url.path, 'Referer' => WHOIS_REFERER)
      req.set_form_data('lang' => 'en', 'domain' => post_domain.first, 'dom' => ".#{post_domain.last}")
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req)}

      if res.code.to_i == 200
        doc = Nokogiri::HTML(res.body)
      else
        raise UnknownError, "Server responded with code #{res.code}"
      end

      if doc.at_xpath('//table[4]/tr/td[2]/table[2]/tr[3]/td[1]').try(:text).try(:strip) == 'This domain is free.'
        @free = true
      end

      doc.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr').each do |registrant|
        @organization = registrant.at_xpath('td[2]/table/tr[1]/td[2]').try(:text)
        @name         = registrant.at_xpath('td[2]/table/tr[2]/td[2]').try(:text)
        @address      = registrant.at_xpath('td[3]/table/tr[1]/td[2]').try(:text)
        @phone        = registrant.at_xpath('td[3]/table/tr[2]/td[2]').try(:text)
        @fax          = registrant.at_xpath('td[3]/table/tr[3]/td[2]').try(:text)
        @email        = registrant.at_xpath('td[3]/table/tr[4]/td[2]').try(:text)
      end

      @name ||= @organization
      @organization = nil if @name == @organization

      doc.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr/td[4]/table').each do |nameserver|
        @nameservers = {
          :ns1 => nameserver.at_xpath('tr[2]/td[2]').try(:text),
          :ns2 => nameserver.at_xpath('tr[3]/td[2]').try(:text),
          :ns3 => nameserver.at_xpath('tr[4]/td[2]').try(:text),
          :ns4 => nameserver.at_xpath('tr[5]/td[2]').try(:text),
          :ns5 => nameserver.at_xpath('tr[6]/td[2]').try(:text),
          :ns6 => nameserver.at_xpath('tr[7]/td[2]').try(:text),
          :ns7 => nameserver.at_xpath('tr[8]/td[2]').try(:text),
          :ns8 => nameserver.at_xpath('tr[9]/td[2]').try(:text)
        }
      end

      @nameservers.delete_if {|k, v| v.nil?} unless @nameservers.nil?
    end
  end
end
