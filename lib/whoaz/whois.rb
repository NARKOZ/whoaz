module Whoaz
  class Whois
    # @return [String] The queried domain name.
    attr_reader :domain

    # @return [String] The name of the registrant.
    attr_reader :name

    # @return [String, nil] The organization of the registrant, or nil.
    attr_reader :organization

    # @return [String] The address of the registrant.
    attr_reader :address

    # @return [String] The phone of the registrant.
    attr_reader :phone

    # @return [String] The fax of the registrant.
    attr_reader :fax

    # @return [String] The email of the registrant.
    attr_reader :email

    # @return [Array] An array of nameservers.
    attr_reader :nameservers

    # Initializes a new Whois object.
    #
    # @param  [String] domain The domain name required to query.
    # @return [Whoaz::Whois]
    def initialize(domain)
      @domain = domain

      response.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr').each do |registrant|
        @organization = get_text registrant.at_xpath('td[2]/table/tr[1]/td[2]')
        @name         = get_text registrant.at_xpath('td[2]/table/tr[2]/td[2]')
        @address      = get_text registrant.at_xpath('td[3]/table/tr[1]/td[2]')
        @phone        = get_text registrant.at_xpath('td[3]/table/tr[2]/td[2]')
        @fax          = get_text registrant.at_xpath('td[3]/table/tr[3]/td[2]')
        @email        = get_text registrant.at_xpath('td[3]/table/tr[4]/td[2]')
      end

      response.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr/td[4]/table').each do |nameserver|
        @nameservers = [
          get_text(nameserver.at_xpath('tr[2]/td[2]')),
          get_text(nameserver.at_xpath('tr[3]/td[2]')),
          get_text(nameserver.at_xpath('tr[4]/td[2]')),
          get_text(nameserver.at_xpath('tr[5]/td[2]')),
          get_text(nameserver.at_xpath('tr[6]/td[2]')),
          get_text(nameserver.at_xpath('tr[7]/td[2]')),
          get_text(nameserver.at_xpath('tr[8]/td[2]')),
          get_text(nameserver.at_xpath('tr[9]/td[2]'))
        ]
      end

      @nameservers.compact! unless @nameservers.nil?
      @name, @organization = @organization, nil if @name.nil?

      if @name.nil? && @organization.nil?
        raise DomainNameError, "Whois query for this domain name is not supported." if not_supported?(response)
      end
    end

    # Checks if the domain name is a free or not.
    #
    # @return [Boolean]
    def free?
      get_text(response.at_xpath('//table[4]/tr/td[2]/table[2]/tr[3]/td')) == 'This domain is free.'
    end
    alias_method :available?, :free?

    # Checks if the domain name is a registered or not.
    #
    # @return [Boolean]
    def registered?
      !free?
    end

    private

    def response
      @response ||= query
    end

    def query
      post_domain = @domain.split('.', 2)
      raise InvalidDomain, "Invalid domain name is specified" unless
        [MAIN_TLD, REGIONAL_TLD].any? {|a| a.include? post_domain.last}

      url = URI WHOIS_URL
      req = Net::HTTP::Post.new(url.path, 'Referer' => WHOIS_REFERER)
      req.set_form_data(:lang => 'en', :domain => post_domain.first, :dom => ".#{post_domain.last}")
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req)}

      if res.code.to_i == 200
        Nokogiri::HTML res.body
      else
        raise ServerError, "Server responded with code #{res.code}"
      end
    end

    def not_supported?(response)
      get_text(response.at_xpath('//table[4]/tr/td[2]/table[2]/td/p')) ==
          'Using of domain names contains less than 3 symbols is not allowed'
    end

    def get_text(nokogiri_element)
      nokogiri_element.text.strip unless nokogiri_element.nil?
    end
  end
end
