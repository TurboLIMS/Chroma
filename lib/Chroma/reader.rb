module Chroma
  include Errors
  include Helper

  class Reader

    attr_accessor :content_type,
                  :checksum,
                  :download,
                  :opts,
                  :debug,
                  :header,
                  :rows

    # ActiveStorage::Blob
    def initialize(active_storage_blob, opts = {})
      self.content_type = active_storage_blob.content_type
      self.checksum = active_storage_blob.checksum
      self.download = active_storage_blob.download
      self.opts  = opts.reject{ |_,v| v.nil? || v == '' }
      self.debug = opts[:debug]

      self.rows = []
      parse!
    end

    def valid_filetype?
      content_type == 'text/csv' || content_type == 'text/pdf'
    end

    def parsed?
      rows.any?
    end

    def to_csv
      if header
        CSV.generate do |csv|
          csv << header
          rows.each {|row| csv << row }
        end
      end
    end

    def to_mapped
      rows.map{|line| Hash[[header,line].transpose] }
    end

    private

    def parse!
      raise Chroma::NotSupported.new("file type not supported: #{input}") if !valid_filetype?

      case content_type
      when 'text/pdf'
        parse_pdf
      when 'text/csv'
        parse_csv
      end

      true
    end

    def parse_pdf
      reader = PDF::Reader.new(StringIO.new(download))
      lines  = reader.pages.first.text.split(%r(\n))
      while (line = lines.shift)

        if !header && line =~ Helper.maybe_regex(opts[:header_regex])
          header_column_regex = opts[:header_column_regex] || opts[:column_regex]
          self.header = line.strip.split(Helper.maybe_regex(header_column_regex))
          if opts[:header_skip_column] || opts[:skip_column]
            (opts[:header_skip_column] || opts[:skip_column]).each {|idx| self.header[idx] = nil }
            self.header.compact!
          end
          header.unshift(opts[:header_prepend]) if opts[:header_prepend]
          header.push(opts[:header_append]) if opts[:header_append]
        end

        if header && line =~ Helper.maybe_regex(opts[:row_regex])
          row = line
          row.gsub!(Helper.maybe_regex(opts[:row_regex]),'') if opts[:should_scrub_re]
          row = row.strip.split(Helper.maybe_regex(opts[:column_regex]))
          if opts[:skip_column]
            opts[:skip_column].each {|idx| row[idx] = nil }
            row.compact!
          end

          next unless row.length == header.length
          next if opts[:reject_sample_regex] && row[0] =~ Helper.maybe_regex(opts[:reject_sample_regex])
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

    def parse_csv
      lines = CSV.parse(download)

      # TBD skip column, reorder column
      # while (line = lines.shift)
      # end

      header =
        if opts[:header_provide]
          opts[:header_provide]
        elsif opts[:header_replace]
          lines.shift
          opts[:header_replace]
        else
          lines.shift.map(&:downcase)
        end

      self.header = header
      self.rows   = lines

    end

    def configuration
      Chroma.configuration
    end
  end
end
