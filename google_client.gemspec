Gem::Specification.new do |s|
  s.name        = 'rp-google_client'
  s.version     = '0.1.0-alpha'
  s.date        = '2019-01-11'
  s.summary     = "Google Client to manage group!"
  s.description = "Api Wrapper to manage Google Groups"
  s.authors     = ["Aravind Syam"]
  s.email       = 'aravind@redpanthers.co'
  s.files       = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.homepage    = 'https://crmified.com'

  s.license     = 'MIT'

  s.add_runtime_dependency 'google-api-client', '~> 0.11'
end
