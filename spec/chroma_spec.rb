require 'spec_helper'
require 'ostruct'

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


  context "when given a file path (PDF)" do

    it "parses a PDF file (report_1) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_1.pdf')
          ),
          debug: true,
          header_regex: %r(\s*Sample\s+),
          row_regex: %r(^\s([*#]){1,2}\s),
          column_regex: %r(\s+),
          should_scrub_re: true
        )
      expect { parser }
        .not_to raise_error

      expect(parser.parsed?).to be true
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(8)
    end

    it "rejects incorrect, nil and empty options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_1.pdf')
          ),
          debug: true,
          header_regex: %r(\s*Sample\s+),
          ainz: 100,
          header_prepend: "",
          row_regex: %r(^\s([*#]){1,2}\s),
          column_regex: %r(\s+),
          should_scrub_re: true
        )
      expect { parser }
        .not_to raise_error

      expect(parser.parsed?).to be true
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(8)
    end

    it "generates a valid CSV from PDF (report_1) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_1.pdf')
          ),
          debug: true,
          header_regex: %r(\s*Sample\s+),
          row_regex: %r(^\s([*#]){1,2}\s),
          column_regex: %r(\s+),
          should_scrub_re: true
        )
      expect { parser }
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
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_2.pdf')
          ),
          debug: true,
          header_regex: %r(Sample ID \|\|),
          header_column_regex: %r(\s\|\|\s),
          row_regex: %r(^Sample_),
          column_regex: %r(\s+),
          should_scrub_re: false
        )

        expect { parser }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID","CBDV","THCV","CBD","CBG","CBDA","CBGA","CBN","THC","d8-THC","CBC","THCA"])
      expect(parser.rows.count).to eq(3)
    end

    it "generates a valid CSV from PDF (report_2) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_2.pdf')
          ),
          debug: true,
          header_regex: %r(Sample ID \|\|),
          header_column_regex: %r(\s\|\|\s),
          row_regex: %r(^Sample_),
          column_regex: %r(\s+),
          should_scrub_re: false
        )
      expect { parser }
        .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,CBDV,THCV,CBD,CBG,CBDA,CBGA,CBN,THC,d8-THC,CBC,THCA\n\
Sample_23,781.674,507.096,662.184,678.83,109.636,581.873,500.424,651.328,596.718,64.142,122.673\n\
Sample_35,683.892,317.118,359.568,13.52,735.353,218.804,381.964,625.032,781.882,685.874,856.873\n\
Sample_37,341.68,780.786,679.52,843.436,613.123,729.566,94.02,454.303,584.151,152.453,230.487\n")
    end

    it "parses a PDF file (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_3.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID", "_THC","_CBD","_CBN"])
      expect(parser.rows.count).to eq(2)
    end

    it "generates a valid CSV from PDF (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_3.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,_THC,_CBD,_CBN\n99,0.03 %,0.0 %,8.2 %\n100,0.0 %,12.7 %,0.0%\n")
    end

    it "skips columns programmatically with skip_column" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_5.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true
        )

      expect { parser }
        .not_to raise_error
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(17)
    end

    it "accepts strings as regular expressions" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_5.pdf')
          ),
          debug: true,
          header_regex: "^\s+Sample\s+",
          skip_column: [1,3,5,7,9,11],
          row_regex: "^\s*\#\s+",
          column_regex: /\s+/,
          should_scrub_re: true
        )

      expect { parser }
        .not_to raise_error
      expect(parser.header).to eq(["Sample", "CBDA", "CBG", "CBD", "CBN", "THC", "THCA"])
      expect(parser.rows.count).to eq(17)
    end

    it "skip sample-id programmatically with reject_sample_regex" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_5.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )

      expect { parser }
        .not_to raise_error
      expect(parser.rows.count).to eq(14)
    end

    it "reorders columns programmatically with header_sort" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_5.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          header_sort: %w(Sample THC THCA CBD CBDA CBN CBG),
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )

      expect { parser }
        .not_to raise_error

      expect(parser.header).to eq(["Sample", "THC", "THCA", "CBD", "CBDA", "CBN", "CBG"])
      expect(parser.rows.find{|row| row[0] == '9439'}).to eq(["9439", "2492.06452", "0.00000", "2.91509", "0.00000", "136.54918", "0.00000"])
    end

    it "rejects an incompatible header_sort directive" do
      expect{
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_5.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+Sample\s+),
          skip_column: [1,3,5,7,9,11],
          header_sort: %w(Sample Thc_ Thca_ Cbd_ Cbda_ Cbn_ Cbg_),
          row_regex: %r(^\s*\#\s+),
          column_regex: %r(\s+),
          should_scrub_re: true,
          reject_sample_regex: %r(\D)
        )
      }.to raise_error(Chroma::Errors::BadInput)



    end
  end

  context "when given a file" do
    it "parses a PDF file (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_3.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser }
          .not_to raise_error

      expect(parser.header).to eq(["Sample ID", "_THC","_CBD","_CBN"])
      expect(parser.rows.count).to eq(2)
    end

    it "generates a valid CSV from PDF (report_3) given the correct options" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/pdf',
            checksum: 'spec',
            download: File.read('./spec/report_3.pdf')
          ),
          debug: true,
          header_regex: %r(^\s+_),
          header_prepend: 'Sample ID',
          row_regex: %r(\s%),
          column_regex: %r(\s{2,}),
          should_scrub_re: false
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_csv).to eq("Sample ID,_THC,_CBD,_CBN\n99,0.03 %,0.0 %,8.2 %\n100,0.0 %,12.7 %,0.0%\n")
    end

  end

  context "when given a file path (CSV)" do

    it "parses the content correctly (report_1)" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/csv',
            checksum: 'spec',
            download: File.read('./spec/report_1.csv')
          ),
          debug: true
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_csv).to eq("sample_identity,cannabinoid_tetrahydrocannabinol_acid,cannabinoid_tetrahydrocannabinol,cannabinoid_cannabidiol,cannabinoid_cannabidiol_acid,cannabinoid_cannabigerol,cannabinoid_cannabinol\nMEOH-001,0.00025100000000000003,0.000298,9.2e-05,9.900000000000002e-05,0.00015900000000000002,0.000127\n3PARTSCBG_CCV-001,10.794871,12.332364000000002,10.964675,12.395207000000001\nTHCACBDA_CCV-001,9.084457,7.799966\n190307-001,6455.740000000001,5987.590000000001,8320.79,6368.1,5316.75,6600.88\n190307-002,9218.529999999999,9273.98,1586.03,7658.77,5128.75,3592.23\n")
    end

    it "replaces the header with the given header (report_2)" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/csv',
            checksum: 'spec',
            download: File.read('./spec/report_2.csv')
          ),
          debug: true,
          header_replace: %w[sample_identity cannabinoid_tetrahydrocannabinol_acid cannabinoid_tetrahydrocannabinol cannabinoid_cannabidiol cannabinoid_cannabidiol_acid cannabinoid_cannabigerol cannabinoid_cannabinol]
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_csv).to eq("sample_identity,cannabinoid_tetrahydrocannabinol_acid,cannabinoid_tetrahydrocannabinol,cannabinoid_cannabidiol,cannabinoid_cannabidiol_acid,cannabinoid_cannabigerol,cannabinoid_cannabinol\nMEOH,1.9e-05,0.000329,5.2e-05,2.7e-05,0.000226,0.000108\n3PARTSCBG_CCV,7.658954,11.069287,8.205603,9.12997\nTHCACBDA_CCV,8.195203000000001,10.699973\n190307-003-10,1406.06,3869.2900000000004,4425.679999999999,7668.61,4599.49,4979.38\n190307-004-10,7651.78,6975.509999999999,725.47,699.98,4385.72,2354.0\nMEOH_B,0.000191,0.000179,3.7000000000000005e-05,5.5e-05,0.00016500000000000003,0.00014800000000000002\n")
    end

    it "provides a header (report_3)" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/csv',
            checksum: 'spec',
            download: File.read('./spec/report_3.csv')
          ),
          debug: true,
          header_provide: %w[sample_identity cannabinoid_tetrahydrocannabinol_acid cannabinoid_tetrahydrocannabinol cannabinoid_cannabidiol cannabinoid_cannabidiol_acid cannabinoid_cannabigerol cannabinoid_cannabinol]
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_csv).to eq("sample_identity,cannabinoid_tetrahydrocannabinol_acid,cannabinoid_tetrahydrocannabinol,cannabinoid_cannabidiol,cannabinoid_cannabidiol_acid,cannabinoid_cannabigerol,cannabinoid_cannabinol\nMEOH,1.9e-05,0.000329,5.2e-05,2.7e-05,0.000226,0.000108\n3PARTSCBG_CCV,7.658954,11.069287,8.205603,9.12997\nTHCACBDA_CCV,8.195203000000001,10.699973\n190307-003-10,1406.06,3869.2900000000004,4425.679999999999,7668.61,4599.49,4979.38\n190307-004-10,7651.78,6975.509999999999,725.47,699.98,4385.72,2354.0\nMEOH_B,0.000191,0.000179,3.7000000000000005e-05,5.5e-05,0.00016500000000000003,0.00014800000000000002\n")
    end

  end

  context "final mapping" do
    it "parses the content correctly (report_1)" do
      parser =
        Chroma::Reader.new(
          OpenStruct.new(
            content_type: 'text/csv',
            checksum: 'spec',
            download: File.read('./spec/report_4.csv')
          ),
          debug: true
        )

        expect { parser }
          .not_to raise_error

      expect(parser.to_mapped).to eq([{'sample' => '1980-20', 'thc' => 12.3342, 'cbd' => 0.2312, 'cbn' => 1.3219}])
    end
  end


  private

  def configure_client
    Chroma.configure do |config|
      config.option = $spec_config['option']
    end
  end

end
