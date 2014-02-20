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
    patron_page.wait_for_page_to_load
    patron_page.wait_for_page_to_load
    patron_page.barcode_field.when_present.set(@patron.barcode)
    patron_page.borrower_type_selector.select(@patron.borrower_type)
    patron_page.activation_date_field.set(today)
    patron_page.first_name_field.set(@patron.first)
    patron_page.last_name_field.set(@patron.last)
    patron_page.address_line.details_link.click
    patron_page.address_line.line_1_field.when_present.set(@patron.address)
    patron_page.address_line.city_field.set(@patron.city)
    patron_page.address_line.state_selector.select(@patron.state)
    patron_page.address_line.postal_code_field.set(@patron.postal_code)
    patron_page.address_line.country_selector.select('United States')
    patron_page.address_line.valid_from_date_field.set(today)
    patron_page.address_line.active_checkbox.set(true)
    patron_page.address_line.add_button.click
    patron_page.address_line.line_number = 2
    patron_page.address_line.line_1_field.wait_until_present
    patron_page.phone_line.phone_number_field.when_present.set(@patron.phone)
    patron_page.phone_line.country_selector.select('United States')
    patron_page.phone_line.active_checkbox.set(true)
    patron_page.phone_line.add_button.click
    patron_page.phone_line.line_number = 2
    patron_page.phone_line.phone_number_field.wait_until_present
    patron_page.email_line.email_address_field.when_present.set(@patron.email)
    patron_page.email_line.active_checkbox.set(true)
    patron_page.email_line.add_button.click
    patron_page.email_line.line_number = 2
    patron_page.email_line.email_address_field.wait_until_present
    patron_page.submit_button.click
    patron_page.wait_for_page_to_load
    patron_page.message.when_present.text.should =~ /success/
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
