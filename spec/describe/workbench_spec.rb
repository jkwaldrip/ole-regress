require 'rspec'
require 'spec_helper.rb'

describe 'The Describe Workbench' do
  include_context 'Create a Marc Record'
  include_context 'Describe Workbench'

  let(:workbench)       { OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole) } 
  let(:author)          { @marc_record.bib_info[0][:value].gsub('|a','') }
  let(:title)           { @marc_record.bib_info[1][:value].gsub('|a','') }
  let(:call_number)     { @marc_record.instance_info[:call_number] }
  let(:barcode)         { @marc_record.item_info[:barcode] }

  it 'starts with a Marc record' do
    bib_editor.open
    new_bib_record
    new_instance
    new_item
  end

  it 'opens' do
    workbench.open
  end

  context 'searches for a bib record' do
    it 'by title' do
      bib_search(workbench, 'Title', title)
    end

    it 'by author' do
      bib_search(workbench, 'Author', author)
    end
  end

  context 'searches for a holdings record' do
    it 'by call number' do
      holdings_search(workbench, 'Call Number', call_number)
    end
  end

  context 'searches for an item record' do
    it 'by barcode' do
      item_search(workbench, 'Item Barcode', barcode)
    end
  end

  it 'retrieves the bib by title' do
    bib_search(workbench, 'Title', title)
  end

  it 'opens the read-only bib' do
    workbench.view_by_text(title).when_present.click
    @ole.windows.count.should eq(2)
    @ole.windows[-1].use
    bib_editor.wait_for_page_to_load
  end

  it 'verifies that title and author are present' do
    bib_editor.readonly_data_field(1).when_present.text.strip.should.include?(author)
    bib_editor.readonly_data_field(2).when_present.text.strip.should.include?(title)
  end
end
