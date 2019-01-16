require 'pdf-reader'
require 'csv'
require 'Chroma/errors'
require 'Chroma/configuration'
require 'Chroma/helper'
require 'Chroma/reader'
require 'Chroma/version'

I18n.load_path += Dir.glob( File.dirname(__FILE__) + "lib/locales/*.{rb,yml}" ) if defined?(I18n)

module Chroma
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end
end
