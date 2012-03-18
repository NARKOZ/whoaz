# encoding: utf-8
require 'spec_helper'

describe Whoaz::Whois do
  it { Whoaz.should respond_to :whois }

  describe "empty domain query" do
    it "should raise EmptyDomain" do
      expect { Whoaz.whois }.to raise_error Whoaz::EmptyDomain, 'Domain not specified'
    end
  end

  describe "invalid domain query" do
    it "should raise InvalidDomain" do
      expect { Whoaz.whois 'google' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain specified'
      expect { Whoaz.whois 'goo.gl' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain specified'
      expect { Whoaz.whois 'алм.az' }.to raise_error Whoaz::InvalidDomain, 'Domain contains non-ASCII characters'
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
        specify { Whoaz.whois('google.az').free?.should be_false }
      end

      describe "#registered?" do
        specify { Whoaz.whois('google.az').registered?.should be_true }
      end

      describe "#available?" do
        specify { Whoaz.whois('google.az').available?.should be_false }
      end
    end

    context "when not registered" do
      before  { fake_url Whoaz::WHOIS_URL, 'free', {:domain => '404', :dom => '.az'} }

      describe "#free?" do
        specify { Whoaz.whois('google.az').free?.should be_true }
      end

      describe "#registered?" do
        specify { Whoaz.whois('404.az').registered?.should be_false }
      end

      describe "#available?" do
        specify { Whoaz.whois('google.az').available?.should be_true }
      end
    end
  end

  context "should return a whois info" do
    context "when a person" do
      before  { fake_url Whoaz::WHOIS_URL, 'person', {:domain => 'johnsmith', :dom => '.az'} }
      subject { Whoaz.whois 'johnsmith.az' }

      describe "#domain" do
        it "should return a domain name" do
          subject.domain.should == 'johnsmith.az'
        end
      end

      describe "#organization" do
        specify { subject.organization.should be_nil }
      end

      describe "#name" do
        it "should return a registrant name" do
          subject.name.should == 'John Smith'
        end
      end
    end

    context "when an organization" do
      before  { fake_url Whoaz::WHOIS_URL, 'organization', {:domain => 'google', :dom => '.az'} }
      subject { Whoaz.whois 'google.az' }

      describe "#domain" do
        it "should return a domain name" do
          subject.domain.should == 'google.az'
        end
      end

      describe "#organization" do
        it "should return a registrant organization" do
          subject.organization.should == 'Google Inc.'
        end
      end

      describe "#name" do
        it "should return a registrant name" do
          subject.name.should == 'Admin'
        end
      end

      describe "#address" do
        it "should return a registrant address" do
          subject.address.should == '94043, Mountain View, 1600 Amphitheatre Parkway'
        end
      end

      describe "#phone" do
        it "should return a registrant phone" do
          subject.phone.should == '+16503300100'
        end
      end

      describe "#fax" do
        it "should return a registrant fax" do
          subject.fax.should == '+16506188571'
        end
      end

      describe "#email" do
        it "should return a registrant email" do
          subject.email.should == 'dns-admin@google.com'
        end
      end

      describe "#nameservers" do
        it "should return domain nameservers" do
          subject.nameservers.should == ["ns1.google.com", "ns2.google.com"]
        end
      end
    end
  end
end
