require 'rspec'
require 'spec_helper.rb'

describe 'The OLE SRU function', :xfer => true do

  include OLE_QA::RegressionTest::Assertions
  include OLE_QA::RegressionTest::MarcEditor
  include OLE_QA::RegressionTest::SRU
  include OLE_QA::RegressionTest::Marc

  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}

  before :all do
    FileUtils::mkdir('data/downloads') unless File.directory?('data/downloads')
    @today                        = Time.now.strftime('%Y%m%d-%H%M')
    @bib_records                  = OpenStruct.new
    @bib_records.target_1         = OLE_QA::Framework::String_Factory.alphanumeric(12)
    @bib_records.target_2         = OLE_QA::Framework::String_Factory.alphanumeric(12)
    @bib_records.year_1           = ('400'..'700').to_a.sample
    @bib_records.year_2           = ('701'..'999').to_a.sample
    @bib_records.record_1         = [
        {:tag => '245',
        :value => "|aTitle One #{@bib_records.target_1}"},
        {:tag => '100',
        :value => "|aAuthor One #{@bib_records.target_2}"},
        {:tag => '260',
        :value => "|c#{@bib_records.year_1}"}
    ]
    @bib_records.record_2         = [
        {:tag => '245',
        :value => "|aTitle Two #{@bib_records.target_1}"},
        {:tag => '100',
        :value => "|aAuthor Two #{@bib_records.target_2}"},
        {:tag => '260',
        :value => "|c#{@bib_records.year_2}"}
    ]
  end

  context 'starts with' do
    it 'one Marc record' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_records.record_1)
      expect(results[:error]).to be_nil
      expect(results[:message]).to match(/success/)
    end

    it 'two Marc records' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_records.record_2)
      expect(results[:error]).to be_nil
      expect(results[:message]).to match(/success/)
    end
  end

  context 'searches by title' do
    it 'with a general search' do
      query         = "title any #{@bib_records.target_1}"
      filename      = "sru_title_any-#{@today}.xml"
      get_sru_file(query,filename,@ole)
      records       = get_marc_xml(filename)
      file_is_empty = File.zero?("data/downloads/#{filename}")
      expect(file_is_empty).to be_false
      expect(records.count).to eq(2)

      records.each do |record|
        title_field = record['245']['a']
        expect(title_field).to match(/Title \w+ #{@bib_records.target_1}/)
      end
    end

    it 'with an exact match' do
      query         = "title = Title One #{@bib_records.target_1}"
      filename      = "sru_title_exact-#{@today}.xml"
      get_sru_file(query,filename,@ole)
      records       = get_marc_xml(filename)
      file_is_empty = File.zero?("data/downloads/#{filename}")
      expect(file_is_empty).to be_false
      expect(records.count).to eq(1)

      records.each do |record|
        title_field = record['245']['a']
        expect(title_field).to match(/Title One #{@bib_records.target_1}/)
      end
    end
  end

  context 'searches by author' do
    it 'with a general search' do
      query         = "author any #{@bib_records.target_2}"
      filename      = "sru_author_any-#{@today}.xml"
      get_sru_file(query,filename,@ole)
      records       = get_marc_xml(filename)
      file_is_empty = File.zero?("data/downloads/#{filename}")
      expect(file_is_empty).to be_false
      expect(records.count).to eq(2)

      records.each do |record|
        author_field = record['100']['a']
        expect(author_field).to match(/Author \w+ #{@bib_records.target_2}/)
      end
    end

    it 'with an exact match' do
      query         = "author = Author One #{@bib_records.target_2}"
      filename      = "sru_year_exact-#{@today}.xml"
      get_sru_file(query,filename,@ole)
      records       = get_marc_xml(filename)
      file_is_empty = File.zero?("data/downloads/#{filename}")
      expect(file_is_empty).to be_false
      expect(records.count).to eq(1)

      records.each do |record|
        author_field = record['100']['a']
        expect(author_field).to match(/Author One #{@bib_records.target_2}/)
      end
    end
  end

  context 'searches by year' do
    # it '> target value' do
    #  This test cannot be implemented until OLE-5791 is resolved.
    #    https://jira.kuali.org/browse/OLE-5791
    # end

    # it '< target value' do
    #  This test cannot be implemented until OLE-5791 is resolved.
    #    https://jira.kuali.org/browse/OLE-5791
    # end

    # it '>= target value' do
    #  This test cannot be implemented until OLE-5791 is resolved.
    #    https://jira.kuali.org/browse/OLE-5791
    # end

    # it '<= target value' do
    #  This test cannot be implemented until OLE-5791 is resolved.
    #    https://jira.kuali.org/browse/OLE-5791
    # end

    # This test cannot be implemented until OLE-5791 is resolved.
    #it '= target value' do
      #query         = "year = #{@bib_records.year_2}"
      #filename      = "sru_author_exact-#{@today}.xml"
      #get_sru_file(query,filename,@ole)
      #records       = get_marc_xml(filename)
      #file_is_empty = File.zero?("data/downloads/#{filename}")
      #expect(file_is_empty).to be_false
      #expect(records.count).to eq(1)

      #records.each do |record|
        #year_field = record['260']['c']
        #expect(year_field).to match(/#{@bib_records.year_2}/)
      #end
    #end
  end

  # context 'searches by publication date' do
  #   it '> target value' do
  #     This test cannot be implemented until OLE-5791 is resolved.
  #       https://jira.kuali.org/browse/OLE-5791
  #   end

  #   it '< target value' do
  #     This test cannot be implemented until OLE-5791 is resolved.
  #       https://jira.kuali.org/browse/OLE-5791
  #   end

  #   it '>= target value' do
  #     This test cannot be implemented until OLE-5791 is resolved.
  #       https://jira.kuali.org/browse/OLE-5791
  #   end

  #   it '<= target value' do
  #     This test cannot be implemented until OLE-5791 is resolved.
  #       https://jira.kuali.org/browse/OLE-5791
  #   end

  #   it '= target value' do
  #     This test cannot be implemented until OLE-5791 is resolved.
  #       https://jira.kuali.org/browse/OLE-5791
  #    end
  # end
end
