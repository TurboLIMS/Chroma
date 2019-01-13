module Chroma
  module Helper
    def self.maybe_regex(obj)
      obj.is_a?(Regexp) ? obj : Regexp.new(obj)
    end
  end
end
