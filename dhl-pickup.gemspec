# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dhl/pickup/version'

Gem::Specification.new do |gem|
  gem.name          = "dhl-pickup"
  gem.version       = Dhl::Pickup::VERSION
  gem.authors       = ["Deseret Book", "Matthew Nielsen", "Luis Castillo"]
  gem.email         = ["mnielsen@deseretbook.com"]
  gem.description   = %q{Request pickup for orders to DHL}
  gem.summary       = %q{Gem to interface with DHL's XML-PI pickup service.}
  gem.homepage      = "https://github.com/lekastillo/dhl-pickup"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'httparty', '~>0.10.2'
  gem.add_dependency 'multi_xml', '~>0.5.3'

  gem.add_development_dependency 'rake', '10.0.4'
  gem.add_development_dependency 'rspec', '2.13.0'
  gem.add_development_dependency 'rspec-must', '0.0.1'
  gem.add_development_dependency 'timecop', '0.6.1'

  if Dhl::Pickup::PostInstallMessage
    gem.post_install_message = Dhl::Pickup::PostInstallMessage
  end

end
