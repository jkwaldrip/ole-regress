require 'rspec'
require 'spec_helper.rb'

describe 'The Marc Editor' do
  include_context 'describe'
  include OLE_QA::RegressionTest::MarcEditor 

  context 'with a new bib record' do
    let(:bib_editor)            { OLE_QA::Framework::OLELS::Bib_Editor.new(@ole) }
    let(:bib_record)           { OpenStruct.new(:bib_ary => 
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
      results = create_bib(bib_editor, bib_record.bib_ary)
      results[:error].should be_nil      
      results[:pass?].should be_true
    end
  end

  context 'with a new holdings record' do
    let(:instance_editor)       { OLE_QA::Framework::OLELS::Instance_Editor.new(@ole) }
    let(:holdings_record)       { OpenStruct.new(:instance_hsh => {
                                    :location         => 'B-EDUC/BED-STACKS',
                                    :call_number      => OLE_QA::Framework::Bib_Factory.call_number,
                                    :call_number_type => 'LCC' })
                                }

    it 'creates a new instance record' do
      results = create_instance(instance_editor, holdings_record.instance_hsh)
      results[:error].should be_nil
      results[:pass?].should be_true
    end
  end

  context 'with a new item record' do
    let(:item_editor)           { OLE_QA::Framework::OLELS::Item_Editor.new(@ole) }
    let(:item_record)           { OpenStruct.new(:item_hsh => {
                                    :item_type        => 'Book',
                                    :item_status      => 'Available',
                                    :barcode          => OLE_QA::Framework::Bib_Factory.barcode })
                                }

    it 'creates a new item record' do
      results = create_item(item_editor, item_record.item_hsh)
      results[:error].should be_nil
      results[:pass?].should be_true
    end
  end
end
