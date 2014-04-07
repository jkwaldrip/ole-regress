require 'rspec'
require 'spec_helper.rb'

describe 'The Describe Workbench' do
  include OLE_QA::RegressionTest::Assertions

  include_context 'Create a Marc Record'
  include_context 'Describe Workbench'

  let(:author)          { @marc_record.bib_info[0][:value].gsub('|a','') }
  let(:title)           { @marc_record.bib_info[1][:value].gsub('|a','') }
  let(:call_number)     { @marc_record.instance_info[:call_number] }
  let(:barcode)         { @marc_record.item_info[:barcode] }

  it 'starts with a Marc record' do
    bib_editor.open
    new_bib_record
    new_instance
    @ole.browser.windows[-1].close
    @ole.browser.windows[0].use
    new_item
    @ole.browser.windows[-1].close
    @ole.browser.windows[0].use
  end

  it 'opens' do
    workbench.open
  end

  context 'searches for a bib record' do
    it 'by title' do
      expect(verify(60) {title_search(title)}).to be_true
    end

    it 'by author' do
      expect(author_search(author)).to be_true
    end
  end

  context 'searches for a holdings record' do
    it 'by call number' do
      expect(call_number_search(call_number)).to be_true
    end
  end

  context 'searches for an item record' do
    it 'by barcode' do
      expect(barcode_search(barcode)).to be_true
    end
  end

  context 'verifies a Marc record' do
    it 'with a title search' do
      title_search(title)
      workbench.title_in_results(title).when_present.click
      expect(@ole.windows.count).to eq(2)
      @ole.windows[-1].use
      bib_editor.wait_for_page_to_load
    end

    it 'by title and author' do
      expect(bib_editor.data_line.data_field.when_present.value.strip.include?(author)).to be_true
      bib_editor.data_line.line_number += 1
      expect(bib_editor.data_line.data_field.when_present.value.strip.include?(title)).to  be_true
    end

    it 'by holdings call number' do
      bib_editor.holdings_link.click
      @ole.browser.windows[-1].use
      instance_editor.wait_for_page_to_load
      expect(instance_editor.call_number_field.when_present.value.strip.include?(call_number)).to be_true
    end

    it 'by item barcode' do
      instance_editor.item_link.click
      @ole.browser.windows[-1].use
      item_editor.wait_for_page_to_load
      expect(item_editor.barcode_field.when_present.value.strip.include?(barcode)).to be_true
    end
  end
end
