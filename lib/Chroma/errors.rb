module Chroma
  module Errors
    class MissingConfiguration < RuntimeError; end
    class MissingParameter < RuntimeError; end
    class NotFound < RuntimeError; end
    class NotSupported < RuntimeError; end
    class BadInput < RuntimeError; end
  end
end
