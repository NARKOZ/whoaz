require 'spec_helper'

describe Whoaz::Whois do
  it { Whoaz.should respond_to :whois }
  it { Whoaz.should respond_to :free? }

  describe "empty domain query" do
    it "should raise EmptyDomain" do
      expect { Whoaz.whois }.to raise_error Whoaz::EmptyDomain, 'Domain not specified'
    end
  end

  describe "invalid domain query" do
    it "should raise InvalidDomain" do
      expect { Whoaz.whois 'google' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain specified'
      expect { Whoaz.whois 'goo.gl' }.to raise_error Whoaz::InvalidDomain, 'Invalid domain specified'
    end
  end

  describe ".free?" do
    before { fake_url Whoaz::WHOIS_URL, 'free', {:domain => '404', :dom => '.az'} }

    it "should return true when domain is free" do
      Whoaz.free?('404.az').should be_true
    end
  end

  context "should return a whois info" do
    context "when a person" do
      before  { fake_url Whoaz::WHOIS_URL, 'person', {:domain => 'johnsmith', :dom => '.az'} }
      subject { Whoaz.whois 'johnsmith.az' }

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
          subject.nameservers.should == {:ns1 => "ns1.google.com", :ns2 => "ns2.google.com"}
        end
      end
    end
  end
end
