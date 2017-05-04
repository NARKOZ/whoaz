# Whoaz [![Build Status](https://travis-ci.org/NARKOZ/whoaz.svg)](http://travis-ci.org/NARKOZ/whoaz)

Whoaz is a ruby gem that provides a nice way to interact with Whois.Az

## Installation

Command line:

```sh
gem install whoaz
```

Bundler:

```ruby
gem 'whoaz', '~> 2.0.0'
```

## Usage

```ruby
whoaz = Whoaz.whois('google.az')
# => #<Whoaz::Whois:0x00000101149158 @organization="Google Inc.", @name="Admin", @address="94043, Mountain View, 1600 Amphitheatre Parkway", @phone="+16503300100", @fax="+16506188571", @email="dns-admin@google.com", @nameservers=["ns1.google.com", "ns2.google.com"]>

whoaz.registered?
# => true
```

#### CLI

```sh
whoaz google.az
```

For more information see: [https://narkoz.github.io/whoaz](https://narkoz.github.io/whoaz)

## Copyright

Released under the BSD 2-clause license. Copyright (c) 2012 Nihad Abbasov
