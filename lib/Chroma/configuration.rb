module Chroma
  class Configuration
    attr_accessor :option

    def incomplete?
      [:option].any? { |e| self.send(e).nil? }
    end

  end
end
