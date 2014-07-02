# coding: utf-8
lib = File.expand_path('../lib/',__FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'ole_regress/VERSION.rb'

Gem::Specification.new do |spec|
  spec.name                     = 'ole-regress'
  spec.version                  = OLE_QA::RegressionTest::VERSION
  spec.authors                  = ['Jain Waldrip']
  spec.email                    = ['jkwaldri@iu.edu']
  spec.description              = 'Kuali OLE Regression Testing Suite'
  spec.summary                  = 'Kuali Open Library Environment Regression Testing'
  spec.homepage                 = 'http://www.github.com/jkwaldrip/ole-regress/'
  spec.license                  = 'ECLv2'

  spec.files                    = `git ls-files`.split($/)
  spec.executables              = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files               = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths            = ['lib']

  spec.required_ruby_version     = '>= 1.9.3'

  spec.add_dependency             'ole-qa-framework', '>= 3.13.4'
  spec.add_dependency             'headless'
  spec.add_dependency             'rspec','~> 2.14.1'
  spec.add_dependency             'chronic'
  spec.add_dependency             'cucumber'
  spec.add_dependency             'bundler'
  spec.add_dependency             'rake'
  spec.add_dependency             'marc'
  spec.add_dependency             'net-http-persistent'
  spec.add_dependency             'numerizer'
end
