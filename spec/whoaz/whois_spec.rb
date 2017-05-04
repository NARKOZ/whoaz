# encoding: utf-8
require 'spec_helper'

describe Whoaz::Whois do
  it { expect(Whoaz).to respond_to :whois }

  describe "empty domain query" do
    it "should raise EmptyDomain" do
      expect { Whoaz.whois }.to raise_error Whoaz::EmptyDomain, 'Domain name is not specified'
    end
  end

  describe "invalid domain query" do
    it "should raise InvalidDomain" do
      expect { Whoaz.whois 'google' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain name is specified'
      expect { Whoaz.whois 'goo.gl' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain name is specified'
      expect { Whoaz.whois 'алм.az' }.to raise_error Whoaz::InvalidDomain, 'Domain name contains non-ASCII characters'
    end
  end

  describe "less than 3 characters long domain query" do
    it "should raise DomainNameError" do
      fake_url Whoaz::WHOIS_URL, 'less_than_3_chars', {:domain => 'i', :dom => '.az'}
      expect { Whoaz.whois 'i.az' }.to raise_error Whoaz::DomainNameError, 'Whois query for this domain name is not supported.'
    end
  end

  context "should check domain registration" do
    context "when registered" do
      before  { fake_url Whoaz::WHOIS_URL, 'organization', {:domain => 'google', :dom => '.az'} }

      describe "#free?" do
        specify { expect(Whoaz.whois('google.az').free?).to be false }
      end

      describe "#registered?" do
        specify { expect(Whoaz.whois('google.az').registered?).to be true }
      end

      describe "#available?" do
        specify { expect(Whoaz.whois('google.az').available?).to be false }
      end
    end

    context "when not registered" do
      before  { fake_url Whoaz::WHOIS_URL, 'free', {:domain => '404', :dom => '.az'} }

      describe "#free?" do
        specify { expect(Whoaz.whois('google.az').free?).to be true }
      end

      describe "#registered?" do
        specify { expect(Whoaz.whois('404.az').registered?).to be false }
      end

      describe "#available?" do
        specify { expect(Whoaz.whois('google.az').available?).to be true }
      end
    end
  end

  context "should return a whois info" do
    context "when a person" do
      before  { fake_url Whoaz::WHOIS_URL, 'person', {:domain => 'johnsmith', :dom => '.az'} }
      subject { Whoaz.whois 'johnsmith.az' }

      describe "#domain" do
        it "should return a domain name" do
          expect(subject.domain).to eq('johnsmith.az')
        end
      end

      describe "#organization" do
        specify { expect(subject.organization).to be_nil }
      end

      describe "#name" do
        it "should return a registrant name" do
          expect(subject.name).to eq('John Smith')
        end
      end
    end

    context "when an organization" do
      before  { fake_url Whoaz::WHOIS_URL, 'organization', {:domain => 'google', :dom => '.az'} }
      subject { Whoaz.whois 'google.az' }

      describe "#domain" do
        it "should return a domain name" do
          expect(subject.domain).to eq('google.az')
        end
      end

      describe "#organization" do
        it "should return a registrant organization" do
          expect(subject.organization).to eq('Google Inc.')
        end
      end

      describe "#name" do
        it "should return a registrant name" do
          expect(subject.name).to eq('Admin')
        end
      end

      describe "#address" do
        it "should return a registrant address" do
          expect(subject.address).to eq('94043, Mountain View, 1600 Amphitheatre Parkway')
        end
      end

      describe "#phone" do
        it "should return a registrant phone" do
          expect(subject.phone).to eq('+16503300100')
        end
      end

      describe "#fax" do
        it "should return a registrant fax" do
          expect(subject.fax).to eq('+16506188571')
        end
      end

      describe "#email" do
        it "should return a registrant email" do
          expect(subject.email).to eq('dns-admin@google.com')
        end
      end

      describe "#nameservers" do
        it "should return domain nameservers" do
          expect(subject.nameservers).to eq(["ns1.google.com", "ns2.google.com"])
        end
      end
    end
  end
end
