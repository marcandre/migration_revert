# -*- encoding: utf-8 -*-
require File.expand_path('../lib/migration_revert/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Marc-Andre Lafortune"]
  gem.email         = ["github@marc-andre.ca"]
  gem.description   = %q{Revert ActiveRecord migrations}
  gem.summary       = %q{Revert ActiveRecord migrations in part or in whole}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "migration_revert"
  gem.require_paths = ["lib"]
  gem.version       = MigrationRevert::VERSION
  gem.add_runtime_dependency('activerecord', [">= 3.1.0"])
end
