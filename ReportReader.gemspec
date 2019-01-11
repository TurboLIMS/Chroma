# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ReportReader/version'

Gem::Specification.new do |spec|
  spec.name          = 'ReportReader'
  spec.version       = ReportReader::VERSION
  spec.authors       = ['Emanuele Tozzato']
  spec.email         = ['etozzato@gmail.com']

  spec.summary       = %q{ReportReader is a PDF and CSV parser for chromatography batch report}
  spec.description   = %q{A simple gem to extract SampleID, Analyte and Concentration from chromatography instruments}
  spec.homepage      = 'https://AINZCorp.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'pdf-reader'
  spec.add_dependency 'bundler', '~> 1.11'
  spec.add_dependency 'rake', '~> 10.1.0'
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
