require 'rspec'
require 'spec_helper.rb'

describe 'The Marc Editor' do
  include_context 'describe'
  include OLE_QA::RegressionTest::MarcEditor 

  context 'with a new bib record' do
    let(:bib_editor)            { OLE_QA::Framework::OLELS::Bib_Editor.new(@ole) }
    let(:marc_record)           { OpenStruct.new(:bib_ary => 
                                    [{:tag    => '100',
                                      :value  => '|a' + OLE_QA::Framework::String_Factory.alphanumeric},
                                    {:tag     => '245',
                                      :value  => '|a' + OLE_QA::Framework::String_Factory.alphanumeric}])
                                 }

    it 'opens the bib editor' do
      bib_editor.open
      bib_editor.wait_for_page_to_load
    end
    
    it 'enters a title and author' do
      results = create_bib(bib_editor, marc_record.bib_ary)
      results[:pass?].should be_true
      results[:error].should be_nil      
    end
  end
end
