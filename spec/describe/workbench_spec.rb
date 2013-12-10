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
      workbench.clear_button.when_present.click
    end

    it 'by author' do
      bib_search(workbench, 'Author', author)
      workbench.clear_button.when_present.click
    end
  end

  context 'searches for a holdings record' do
    it 'by call number' do
      holdings_search(workbench, 'Call Number', call_number)
      workbench.clear_button.when_present.click
    end
  end

  context 'searches for an item record' do
    it 'by barcode' do
      item_search(workbench, 'Item Barcode', barcode)
      workbench.clear_button.when_present.click
    end
  end

  context 'verifies a Marc record' do
    it 'with a title search' do
      bib_search(workbench, 'Title', title)
      workbench.view_by_text(title).when_present.click
      @ole.windows.count.should eq(2)
      @ole.windows[-1].use
      bib_editor.wait_for_page_to_load
    end

    it 'by title and author' do
      bib_editor.readonly_data_field(1).when_present.text.strip.include?(author).should be_true
      bib_editor.readonly_data_field(2).when_present.text.strip.include?(title).should  be_true
    end

    it 'by holdings call number' do
      bib_editor.holdings_link.click
      instance_editor.wait_for_page_to_load
      instance_editor.readonly_call_number.when_present.text.strip.include?(call_number).should be_true
    end

    it 'by item barcode' do
      instance_editor.item_link.click
      item_editor.wait_for_page_to_load
      item_editor.readonly_barcode.when_present.text.strip.include?(barcode).should be_true
    end

    it 'and returns to the main window' do
      @ole.windows[-1].close
      @ole.windows[0].use
    end
  end
end
