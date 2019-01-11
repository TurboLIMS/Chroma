require 'spec_helper'

describe ReportReader do
  before(:each) { configure_client }

  it 'has a version number' do
    expect(ReportReader::VERSION).not_to be nil
  end

  it 'accepts a configuration' do
    ReportReader.configure do |config|
      config.option = '62b28FR37'
    end

    expect(ReportReader.configuration.option).to eq('62b28FR37')
    expect(ReportReader.configuration.incomplete?).to be false
  end


  it 'initializes with no parameters' do

    expect { ReportReader::Base.new }
      .not_to raise_error
  end

  it 'initializes with parameters' do

    expect { ReportReader::Base.new(debug: true) }
      .not_to raise_error
  end

  it "accepts a file name during initialization" do
    parser = ReportReader::Base.new(debug: true, filename: 'file.txt')

    expect(parser.filename).to eq('file.txt')
    expect(parser.valid_file?).to be false
  end

  it "raises an error when parsing is requested without a valid file" do

    parser = ReportReader::Base.new(debug: true)
    expect { parser.parse! }
      .to raise_error(ReportReader::Errors::NotFound)

    parser = ReportReader::Base.new(debug: true, filename: './spec/file.txt')
      expect { parser.parse! }
        .to raise_error(ReportReader::Errors::NotSupported)
  end

  it "parses a PDF file (report_1) given the correct options" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_1.pdf',
        header_regex: %r(\s*Sample\s+),
        row_regex: %r(^\s([*#]){1,2}\s),
        column_regex: %r(\s+),
        should_scrub_regex: true
      )
    expect { parser.parse! }
      .not_to raise_error

    expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
    expect(parser.rows.count).to eq(8)
  end

  it "can generate a valid CSV from PDF (report_1) given the correct options" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_1.pdf',
        header_regex: %r(\s*Sample\s+),
        row_regex: %r(^\s([*#]){1,2}\s),
        column_regex: %r(\s+),
        should_scrub_regex: true
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
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_2.pdf',
        header_regex: %r(Sample ID \|\|),
        header_column_regex: %r(\s\|\|\s),
        row_regex: %r(^Sample_),
        column_regex: %r(\s+),
        should_scrub_regex: false
      )

      expect { parser.parse! }
        .not_to raise_error

    expect(parser.header).to eq(["Sample ID","CBDV","THCV","CBD","CBG","CBDA","CBGA","CBN","THC","d8-THC","CBC","THCA"])
    expect(parser.rows.count).to eq(3)
  end

  it "can generate a valid CSV from PDF (report_2) given the correct options" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_2.pdf',
        header_regex: %r(Sample ID \|\|),
        header_column_regex: %r(\s\|\|\s),
        row_regex: %r(^Sample_),
        column_regex: %r(\s+),
        should_scrub_regex: false
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
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_3.pdf',
        header_regex: %r(^\s+_),
        header_prepend: 'Sample ID',
        row_regex: %r(\s%),
        column_regex: %r(\s{2,}),
        should_scrub_regex: false
      )

      expect { parser.parse! }
        .not_to raise_error

    expect(parser.header).to eq(["Sample ID", "_THC","_CBD","_CBN"])
    expect(parser.rows.count).to eq(2)
  end

  it "can generate a valid CSV from PDF (report_3) given the correct options" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_3.pdf',
        header_regex: %r(^\s+_),
        header_prepend: 'Sample ID',
        row_regex: %r(\s%),
        column_regex: %r(\s{2,}),
        should_scrub_regex: false
      )

      expect { parser.parse! }
        .not_to raise_error

    expect(parser.to_csv).to eq("Sample ID,_THC,_CBD,_CBN\n99,0.03 %,0.0 %,8.2 %\n100,0.0 %,12.7 %,0.0%\n")
  end

  it "can programmatically skip columns" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_5.pdf',
        header_regex: %r(^\s+Sample\s+),
        skip_column: [1,3,5,7,9,11],
        row_regex: %r(^\s*\#\s+),
        column_regex: %r(\s+),
        should_scrub_regex: true
      )

    expect { parser.parse! }
      .not_to raise_error
    expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
    expect(parser.rows.count).to eq(17)
  end

  it "can programmatically skip sample-id" do
    parser =
      ReportReader::Base.new(
        debug: true,
        filename: './spec/report_5.pdf',
        header_regex: %r(^\s+Sample\s+),
        skip_column: [1,3,5,7,9,11],
        row_regex: %r(^\s*\#\s+),
        column_regex: %r(\s+),
        should_scrub_regex: true,
        reject_sample_regex: %r(\D)
      )

    expect { parser.parse! }
      .not_to raise_error
    expect(parser.rows.count).to eq(14)
  end

  

  private

  def configure_client
    ReportReader.configure do |config|
      config.option = $spec_config['option']
    end
  end

end
