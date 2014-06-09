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
    new_item
    @ole.browser.windows[-1].close
    @ole.browser.windows[0].use
  end

  it 'opens' do
    workbench.open
  end

  context 'searches for a bib record' do
    it 'by title' do
      title_found = verify(60) {title_search(title)}
      expect(title_found).to be_true
    end

    it 'by author' do
      author_found = author_search(author)
      expect(author_found).to be_true
    end
  end

  context 'searches for an item record' do
    it 'by barcode' do
      barcode_found = barcode_search(barcode)
      expect(barcode_found).to be_true
    end
  end

  context 'verifies a Marc record' do
    it 'with a title search' do
      title_search(title)
      workbench.title_in_results(title).when_present.click
      windows_present = @ole.windows.count
      expect(windows_present).to eq(2)
      @ole.windows[-1].use
      bib_editor.wait_for_page_to_load
    end

    it 'by title and author' do
      author_present = bib_editor.data_line.data_field.when_present.value.strip.include?(author)
      expect(author_present).to be_true
      bib_editor.data_line.line_number += 1
      title_present = bib_editor.data_line.data_field.when_present.value.strip.include?(title)
      expect(title_present).to be_true
    end

    it 'by holdings call number' do
      bib_editor.holdings_link.click
      @ole.browser.windows[-1].use
      instance_editor.wait_for_page_to_load
      call_number_present = instance_editor.call_number_field.when_present.value.strip.include?(call_number)
      expect(call_number_present).to be_true
    end

    it 'by item barcode' do
      instance_editor.item_link.click
      @ole.browser.windows[-1].use
      item_editor.wait_for_page_to_load
      barcode_present = item_editor.barcode_field.when_present.value.strip.include?(barcode)
      expect(barcode_present).to be_true
    end
  end
end
