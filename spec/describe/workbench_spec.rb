require 'rspec'
require 'spec_helper.rb'

describe 'The Describe Workbench' do
  include_context 'Create a Marc Record'


  let(:workbench)       { OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole) } 
  let(:author)          { @marc_record.bib_info[0][:value].gsub('|a','') }
  let(:title)           { @marc_record.bib_info[1][:value].gsub('|a','') }

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
      workbench.doc_type_bib.when_present.set
      workbench.wait_for_page_to_load
      workbench.search_field_1.when_present.set(title)
      workbench.search_field_selector_1.select('Title')
      workbench.search_button.click
      workbench.wait_for_page_to_load
      workbench.result_present?(title).should be_true
    end
  end
end
