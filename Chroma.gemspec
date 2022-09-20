# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Chroma/version'

Gem::Specification.new do |spec|
  spec.name          = 'Chroma'
  spec.version       = Chroma::VERSION
  spec.authors       = ['Emanuele Tozzato']
  spec.email         = ['etozzato@gmail.com']

  spec.summary       = %q{Chroma is a PDF and CSV parser for chromatography batch report}
  spec.description   = %q{A simple gem to extract SampleID, Analyte and Concentration from chromatography instruments}
  spec.homepage      = 'https://AINZCorp.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'pdf-reader'
  spec.add_dependency 'bundler'
  spec.add_dependency 'rake'
  spec.add_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
