module Chroma
  module Helper
    def self.maybe_regex(obj)
      return unless obj
      obj.is_a?(Regexp) ? obj : Regexp.new(obj) rescue obj
    end
  end
end
