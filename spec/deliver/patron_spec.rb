require 'rspec'
require 'spec_helper.rb'

describe 'A Patron' do

  include OLE_QA::RegressionTest::Assertions
  include_context 'New Patron'

  before :all do
    @patron.new_borrower_type = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    # Ensure a unique value over the current borrower type.
    while @patron.new_borrower_type == @patron.borrower_type
      @patron.new_borrower_type = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    end
  end

  it 'has a new record' do
    patron_lookup.open
    patron_lookup.create_new.when_present.click
    patron_page.wait_for_page_to_load.should be_true
    new_patron(patron_page, @patron)
  end

  context 'is searchable' do
    # Use a verify as this is the first test after record submission.
    # If the search is not repeated, slow system performance will result
    # in a premature failure.
    it 'by barcode' do
      patron_lookup.open
      verify {
        patron_lookup.clear_button.click
        patron_lookup.barcode_field.when_present.set(@patron.barcode)
        patron_lookup.search_button.click
        patron_lookup.wait_for_page_to_load
        patron_lookup.text_in_results?(@patron.barcode)
      }.should be_true
    end

    it 'by name' do
      patron_lookup.clear_button.click
      patron_lookup.wait_for_page_to_load
      patron_lookup.first_name_field.when_present.set(@patron.first)
      patron_lookup.last_name_field.when_present.set(@patron.last)
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      verify {patron_lookup.text_in_results?(@patron.barcode)}.should be_true
    end

    it 'by email' do
      patron_lookup.clear_button.click
      patron_lookup.wait_for_page_to_load
      patron_lookup.email_address_field.when_present.set(@patron.email)
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      verify {patron_lookup.text_in_results?(@patron.barcode)}.should be_true
      patron_lookup.clear_button.click
    end
  end

  context 'is editable' do
    it 'after opening from search results' do
      patron_lookup.open
      patron_lookup.barcode_field.when_present.set(@patron.barcode)
      patron_lookup.first_name_field.when_present.set(@patron.first)
      patron_lookup.last_name_field.when_present.set(@patron.last)
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      Watir::Wait.until { patron_lookup.text_in_results?(@patron.barcode) }
      patron_lookup.edit_by_text(@patron.barcode).when_present.click
      patron_page.wait_for_page_to_load
    end

    it 'and takes a new borrower type' do
      patron_page.borrower_type_selector.when_present.select(@patron.new_borrower_type)
      patron_page.borrower_type_selector.selected?(@patron.new_borrower_type).should be_true
    end

    it 'and persists changes' do
      patron_page.submit_button.click
      verify { patron_page.message.text =~ /success/ }.should be_true
    end

    it 'and verified via search' do
      patron_lookup.open
      patron_lookup.barcode_field.when_present.set(@patron.barcode)
      patron_lookup.first_name_field.when_present.set(@patron.first)
      patron_lookup.last_name_field.when_present.set(@patron.last)
      patron_lookup.text_in_results?(@patron.new_borrower_type)
    end
  end
end
