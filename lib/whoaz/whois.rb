module Whoaz
  class Whois
    # @return [String] The queried domain name.
    attr_reader :domain

    # @return [String] The name of the registrant.
    attr_reader :name

    # @return [String] The organization of the registrant.
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

    # @return [Boolean] Availability of the domain.
    attr_reader :free
    alias_method :free?, :free
    alias_method :available?, :free?

    # Initializes a new Whois object.
    #
    # @param  [String] domain The domain name required to query.
    # @return [Whoaz::Whois]
    def initialize(domain)
      @domain = domain

      if raw_domain_info.include?('is not exists') || raw_domain_info.include?('cannot be registered')
        @free = true
      else
        @free = false
        domain_info = raw_domain_info.split("\n")
        @nameservers  = domain_info[3].sub('Name Servers:', '').strip.split(',')
        @organization = domain_info[16].sub('Organisation:', '').strip
        @name         = domain_info[17].sub('Name:', '').strip
        @address      = domain_info[19..23].join("\n").strip
        @phone        = domain_info[12].sub('Voice phone:', '').strip
        @fax          = domain_info[13].sub('Fax:', '').strip
        @email        = domain_info[11].sub('Email:', '').strip
      end
    end

    # Checks if the domain name is registered or not.
    #
    # @return [Boolean]
    def registered?
      !free?
    end

    # Returns raw domain info as responded by WHOIS server.
    #
    # @return [String]
    def raw_domain_info
      @raw_domain_info ||= query
    end

    private

    def query
      post_domain = @domain.split('.', 2)
      raise InvalidDomain, "Invalid domain name is specified" unless
        (MAIN_TLD + REGIONAL_TLD).include? post_domain.last

      url = URI WHOIS_URL
      req = Net::HTTP::Post.new(url.path, 'Referer' => WHOIS_REFERER)
      req.set_form_data(lang: 'en', domain: post_domain.first, dom: ".#{post_domain.last}")
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req)}

      if res.code.to_i == 200
        page = Nokogiri::HTML res.body
        page.at_xpath('//table[4]/tr/td[2]/table[2]/td[1]/pre').text.strip
      else
        raise ServerError, "WHOIS server responded with status code #{res.code}"
      end
    end
  end
end
