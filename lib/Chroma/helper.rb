module Chroma
  module Helper

    def self.instructions
"# Input options for the Chroma::Reader GEM initialization

# input: File or file_path of the report to read
# header_regex: RE to identify the header row
# header_column_regex: RE to identify the header column separator (overwrites column_regex)
# header_skip_column: array of indexes of columns to ignore (overwrites skip_column)
# header_append: array of elements to append to the header
# header_prepend: array of elements to prepend to the header
# header_sort: array of strings to sepcify the order of columns
# row_regex: RE to indentify data rows
# column_regex: RE to identify the column separator
# skip_column: array of indexes of columns to ignore
# should_scrub_re: RE to remove a ancor from data rows
# reject_sample_regex: RE to reject sample-id"
    end

    def self.options
      %i(
        header_regex
        header_column_regex
        header_skip_column
        header_append
        header_prepend
        header_sort
        row_regex
        column_regex
        skip_column
        should_scrub_re
        reject_sample_regex
      )
    end

    def self.maybe_regex(obj)
      return unless obj
      obj.is_a?(Regexp) ? obj : Regexp.new(obj) rescue obj
    end

  end
end
