module Chroma
  include Errors

  class Reader

    attr_accessor :debug,
                  :opts,
                  :input,
                  :header,
                  :rows

    EXT_REGEX = %r(\.(pdf|csv)\z)

    def initialize(opts = {})
      self.opts  = opts
      self.input = opts[:input]
      self.rows  = []
      self.debug = opts[:debug]
    end

    def self.help
"# Input options for the Chroma::Reader constructor
#
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
# should_scrub_regex: RE to remove a ancor from data rows
# reject_sample_regex: RE to reject sample-id
#"
    end

    def valid_file?
      !input.nil? &&
        ( input.is_a?(File) || File.exist?(input) )
    end

    def filename
      input.respond_to?(:path) ? input.path : input
    end

    def valid_filetype?
      filename =~ EXT_REGEX
    end

    def filetype
      filename.match(EXT_REGEX)[1]
    end

    def parse!
      raise Chroma::NotFound.new("file not found: #{input}") if !valid_file?
      raise Chroma::NotSupported.new("file type not supported: #{input}") if !valid_filetype?

      case filetype
      when 'pdf'
        parse_pdf
      when 'csv'
        raise Chroma::NotSupported.new("not implemented!")
      end

      true
    end

    def to_csv
      if header
        CSV.generate do |csv|
          csv << header
          rows.each {|row| csv << row }
        end
      end
    end

    private

    def parse_pdf
      reader = PDF::Reader.new(input)
      lines  = reader.pages.first.text.split(%r(\n))
      while (line = lines.shift)

        if !header && line =~ opts[:header_regex]
          self.header = line.strip.split(opts[:header_column_regex] || opts[:column_regex])
          if opts[:header_skip_column] || opts[:skip_column]
            (opts[:header_skip_column] || opts[:skip_column]).each {|idx| self.header[idx] = nil }
            self.header.compact!
          end
          header.unshift(opts[:header_prepend]) if opts[:header_prepend]
          header.push(opts[:header_append]) if opts[:header_append]
        end

        if header && line =~ opts[:row_regex]
          row = line
          row.gsub!(opts[:row_regex],'') if opts[:should_scrub_regex]
          row = row.strip.split(opts[:column_regex])
          if opts[:skip_column]
            opts[:skip_column].each {|idx| row[idx] = nil }
            row.compact!
          end

          next unless row.length == header.length
          next if opts[:reject_sample_regex] && row[0] =~ opts[:reject_sample_regex]
          rows.push(row)
        end
      end # end of line parsing

      if opts[:header_sort] && opts[:header_sort] != header
        raise Chroma::BadInput.new(
          "Incorrect header_sort parameter: #{opts[:header_sort].sort} != #{header.sort}"
        ) if opts[:header_sort].sort != header.sort

        index_vector = opts[:header_sort].map {|el| header.index(el)}
        transposed_rows = rows.transpose
        self.header = opts[:header_sort]
        self.rows = index_vector.map {|idx| transposed_rows[idx] }.transpose
      end

    end

    def configuration
      Chroma.configuration
    end
  end
end
