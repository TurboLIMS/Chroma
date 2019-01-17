require 'pdf-reader'
require 'csv'
require 'Chroma/errors'
require 'Chroma/configuration'
require 'Chroma/helper'
require 'Chroma/reader'
require 'Chroma/version'

module Chroma

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end
end
