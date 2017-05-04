require 'rspec'
require 'fakeweb'
require 'whoaz'

FakeWeb.allow_net_connect = false

# Patch for Ruby >= 2.2
# https://github.com/chrisk/fakeweb/pull/59
module FakeWeb
  class StubSocket
    def close
    end
  end
end

def load_fixture(name)
  File.open(File.dirname(__FILE__) + "/fixtures/#{name}.html").read
end

def fake_url(url, fixture_name, params)
  FakeWeb.register_uri(:post, url, :body => load_fixture(fixture_name), :parameters => {:lang => 'en'}.merge(params))
end
