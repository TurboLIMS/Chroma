require 'spec_helper'

describe Chroma do
  before(:each) { configure_client }

  it 'has a version number' do
    expect(Chroma::VERSION).not_to be nil
  end

  it 'accepts a configuration' do
    Chroma.configure do |config|
      config.option = '62b28FR37'
    end

    expect(Chroma.configuration.option).to eq('62b28FR37')
    expect(Chroma.configuration.incomplete?).to be false
  end


  it 'initializes with no parameters' do

    expect { Chroma::Reader.new }
      .not_to raise_error
  end

  it 'initializes with parameters' do

    expect { Chroma::Reader.new(debug: true) }
      .not_to raise_error
  end

  it 'is not parsed? at initialization' do
    parser = Chroma::Reader.new(debug: true)

    expect(parser.parsed?).to be false
  end

  it "accepts a file name during initialization" do
    parser = Chroma::Reader.new(debug: true, input: 'file.txt')

    expect(parser.input).to eq('file.txt')
    expect(parser.valid_file?).to be false
  end

  it "raises an error when parsing is requested without a valid file" do

    parser = Chroma::Reader.new(debug: true)
    expect { parser.parse! }
      .to raise_error(Chroma::Errors::NotFound)

    parser = Chroma::Reader.new(debug: true, input: './spec/file.txt')
      expect { parser.parse! }
        .to raise_error(Chroma::Errors::NotSupported)
  end

  context "when given a file path" do

    it "parses a PDF file (report_1) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_1.pdf',
          header_regex: %r(\s*Sample\s+),
          row_regex: %r(^\s([*#]){1,2}\s),
          column_regex: %r(\s+),
          should_scrub_re: true
        )
      expect { parser.parse! }
        .not_to raise_error

      expect(parser.parsed?).to be true
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(8)
    end

    it "generates a valid CSV from PDF (report_1) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_1.pdf',
          header_regex: %r(\s*Sample\s+),
          row_regex: %r(^\s([*#]){1,2}\s),
          column_regex: %r(\s+),
          should_scrub_re: true
        )
      expect { parser.parse! }
        .not_to raise_error

      expect(parser.to_csv).to eq(
        "Sample,CBDA,CBG,CBD,CBN,THC,THCA\n\
MEOH,0.00000,0.00000,0.00000,0.00000,2.47321e-1,7.68054\n\
EXCALX40,10.75298,3.03104,5.85689e-1,0.00000,9.21048e-1,7.81001\n\
PRIMARYSTD,117.24645,104.00027,103.49049,121.21343,120.62042,115.64153\n\
32553,326.93862,240.90205,39.74956,0.00000,348.44571,9403.31596\n\
32579,4.07320,3.02030,4.84979e-1,0.00000,1.24342,106.60768\n\
32580,4.07715,2.96655,3.75842e-1,0.00000,3.36109,99.99370\n\
CCV1,0.00000,0.00000,0.00000,0.00000,0.00000,0.00000\n\
CCV1,0.00000,0.00000,0.00000,0.00000,0.00000,0.00000\n")
    end

    it "parses a PDF file (report_2) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_2.pdf',
          header_regex: %r(Sample ID \|\|),
          header_column_regex: %r(\s\|\|\s),
          row_regex: %r(^Sample_),
          column_regex: %r(\s+),
          should_scrub_re: false
        )

        expect { parser.parse! }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID","CBDV","THCV","CBD","CBG","CBDA","CBGA","CBN","THC","d8-THC","CBC","THCA"])
      expect(parser.rows.count).to eq(3)
    end

    it "generates a valid CSV from PDF (report_2) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_2.pdf',
          header_regex: %r(Sample ID \|\|),
          header_column_regex: %r(\s\|\|\s),
          row_regex: %r(^Sample_),
          column_regex: %r(\s+),
          should_scrub_re: false
        )
      expect { parser.parse! }
        .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,CBDV,THCV,CBD,CBG,CBDA,CBGA,CBN,THC,d8-THC,CBC,THCA\n\
Sample_23,781.674,507.096,662.184,678.83,109.636,581.873,500.424,651.328,596.718,64.142,122.673\n\
Sample_35,683.892,317.118,359.568,13.52,735.353,218.804,381.964,625.032,781.882,685.874,856.873\n\
Sample_37,341.68,780.786,679.52,843.436,613.123,729.566,94.02,454.303,584.151,152.453,230.487\n")
    end

    it "parses a PDF file (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_3.pdf',
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser.parse! }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID", "_THC","_CBD","_CBN"])
      expect(parser.rows.count).to eq(2)
    end

    it "generates a valid CSV from PDF (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_3.pdf',
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser.parse! }
          .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,_THC,_CBD,_CBN\n99,0.03 %,0.0 %,8.2 %\n100,0.0 %,12.7 %,0.0%\n")
    end

    it "skips columns programmatically with skip_column" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_5.pdf',
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true
        )

      expect { parser.parse! }
        .not_to raise_error
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(17)
    end

    it "accepts strings as regular expressions" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_5.pdf',
          header_regex: "^\s+Sample\s+",
          skip_column: [1,3,5,7,9,11],
          row_regex: "^\s*\#\s+",
          column_regex: /\s+/,
          should_scrub_re: true
        )

      expect { parser.parse! }
        .not_to raise_error
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(17)
    end

    it "skip sample-id programmatically with reject_sample_regex" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_5.pdf',
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )

      expect { parser.parse! }
        .not_to raise_error
      expect(parser.rows.count).to eq(14)
    end

    it "reorders columns programmatically with header_sort" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_5.pdf',
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          header_sort: %w(Sample THC THCA CBD CBDA CBN CBG),
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )

      expect { parser.parse! }
        .not_to raise_error

      expect(parser.header).to eq(["Sample", "THC", "THCA", "CBD", "CBDA", "CBN", "CBG"])
      expect(parser.rows.find{|row| row[0] == '9439'}).to eq(["9439", "2492.06452", "0.00000", "2.91509", "0.00000", "136.54918", "0.00000"])
    end

    it "rejects an incompatible header_sort directive" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: './spec/report_5.pdf',
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          header_sort: %w(Sample Thc_ Thca_ Cbd_ Cbda_ Cbn_ Cbg_),
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )

      expect { parser.parse! }
        .to raise_error(Chroma::Errors::BadInput)
    end
  end

  context "when given a file" do
    it "parses a PDF file (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: File.open('./spec/report_3.pdf'),
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser.parse! }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID", "_THC","_CBD","_CBN"])
      expect(parser.rows.count).to eq(2)
    end

    it "generates a valid CSV from PDF (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          debug: true,
          input: File.open('./spec/report_3.pdf'),
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser.parse! }
          .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,_THC,_CBD,_CBN\n99,0.03 %,0.0 %,8.2 %\n100,0.0 %,12.7 %,0.0%\n")
    end

  end

  private

  def configure_client
    Chroma.configure do |config|
      config.option = $spec_config['option']
    end
  end

end
