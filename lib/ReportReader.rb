require 'pdf-reader'
require 'csv'
require 'ReportReader/constants'
require 'ReportReader/errors'
require 'ReportReader/configuration'
require 'ReportReader/base'
require "ReportReader/version"

module ReportReader
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end
end
