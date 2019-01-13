require 'yaml'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$spec_config = YAML.load_file('./spec/spec_config.yml')

require 'Chroma'
