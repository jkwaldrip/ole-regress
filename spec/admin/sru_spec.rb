require 'rspec'
require 'spec_helper.rb'

describe 'The OLE SRU function' do

  include OLE_QA::RegressionTest::Assertions
  include OLE_QA::RegressionTest::MarcEditor

  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}

  before :all do
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
      results[:error].should be_nil
      results[:message].should =~ /success/
    end

    it 'two Marc records' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_records.record_2)
      results[:error].should be_nil
      results[:message].should =~ /success/
    end
  end

  context 'searches by title' do
    it 'with a general search' do

    end

    it 'with an exact match' do

    end
  end

  context 'searches by author' do
    it 'with a general search' do

    end

    it 'with an exact match' do

    end
  end

  context 'searches by year' do
    it '> target value' do

    end

    it '< target value' do

    end

    it '>= target value' do

    end

    it '<= target value' do

    end

    it '= target value' do

    end
  end

  context 'searches by publication date' do
    it '> target value' do

    end

    it '< target value' do

    end

    it '>= target value' do

    end

    it '<= target value' do

    end

    it '= target value' do

    end
  end
end