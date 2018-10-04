lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cryptostream/version'

Gem::Specification.new do |s|
  s.name = 'cryptostream'
  s.version = Cryptostream::VERSION
  s.authors = ['Jake Craige']
  s.email = ['todo@example.com']

  s.summary = 'Cryptostream is gem designed to make getting a stream of blocks from arbitrary blockchains easy.'
  s.homepage = 'https://github.com/jakecraige/cryptostream'

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  s.require_paths = ['lib']

  s.add_dependency 'bitcoin-ruby', '~> 0.0.18'
  # NOTE: This dependency is a private dependency so until we move off it it's not possible to run
  # this locally.
  s.add_dependency 'cb-ethereum', '~> 6.0'
  s.add_dependency 'faraday', '~> 0.13'
  s.add_dependency 'faraday_middleware', '~> 0.12'
  s.add_dependency 'typhoeus', '~> 1.3.0'
end
