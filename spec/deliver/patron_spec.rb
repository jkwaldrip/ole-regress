require 'rspec'
require 'spec_helper.rb'

describe 'A Patron' do

  include OLE_QA::RegressionTest::Assertions
  include_context 'New Patron'

  before :all do
    @patron[:new_borrower_type] = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    # Ensure a unique value over the current borrower type.
    while @patron[:new_borrower_type] == @patron[:borrower_type]
      @patron[:new_borrower_type] = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    end
  end

  context 'has a new record' do
    it 'with a barcode' do
      patron_lookup.open
      patron_lookup.create_new.when_present.click
      patron_page.wait_for_page_to_load
      patron_page.wait_for_page_to_load
      set_field(patron_page.barcode_field,@patron[:barcode])
    end

    it 'with a borrower type' do
      set_field(patron_page.borrower_type_selector,@patron[:borrower_type])
    end 

    it 'with a first name' do
      set_field(patron_page.first_name_field,@patron[:first])
    end

    it 'with a last name' do
      set_field(patron_page.last_name_field,@patron[:last])
    end

    it 'with an address source of Operator' do
      set_field(patron_page.address_line.address_source_selector,'Operator')
    end

    it 'with address details' do
      patron_page.address_line.details_link.click
      address_details_present = patron_page.address_line.line_1_field.wait_until_present
      expect(address_details_present).to be_true
    end

    it 'with an address type' do
      set_field(patron_page.address_line.address_type_selector,'Home')
    end

    it 'with an address' do
      set_field(patron_page.address_line.line_1_field,@patron[:address])
    end
   
    it 'with a city' do
      set_field(patron_page.address_line.city_field,@patron[:city])
    end

    it 'with a state' do
      set_field(patron_page.address_line.state_selector,@patron[:state])
    end
    
    it 'with a postal code' do
      set_field(patron_page.address_line.postal_code_field,@patron[:postal_code])
    end

    it 'with a country' do
      set_field(patron_page.address_line.country_selector,'United States')
      set_field(patron_page.phone_line.country_selector,'United States')
    end

    it 'with the address active' do
      set_field(patron_page.address_line.active_checkbox,true)
    end

    it 'with the address added' do
      patron_page.address_line.add_button.click
      patron_page.address_line.line_number = 2
      address_is_added = patron_page.address_line.line_1_field.wait_until_present
      expect(address_is_added).to be_true
    end

    it 'with an email address' do
      set_field(patron_page.email_line.email_address_field,@patron[:email])
    end

    it 'with the email address active' do
      set_field(patron_page.email_line.active_checkbox,true)
    end

    it 'with the email address added' do
      patron_page.email_line.add_button.click
      patron_page.email_line.line_number = 2
      email_is_added = patron_page.email_line.email_address_field.wait_until_present
      expect(email_is_added).to be_true
    end

    it 'with a phone number' do
      set_field(patron_page.phone_line.phone_number_field,@patron[:phone])
    end

    it 'with the phone number active' do
      set_field(patron_page.phone_line.active_checkbox,true)
    end

    it 'with the phone number added' do
      patron_page.phone_line.add_button.click
      patron_page.phone_line.line_number = 2
      phone_is_added = patron_page.phone_line.phone_number_field.wait_until_present
      expect(phone_is_added).to be_true
    end

    it 'successfully submitted' do
      patron_page.submit_button.click
      patron_page.wait_for_page_to_load
      expect(patron_page.message.when_present.text).to match(/success/)
    end
  end

  context 'is searchable' do
    # Use a verify as this is the first test after record submission.
    # If the search is not repeated, slow system performance will result
    # in a premature failure.
    it 'by barcode' do
      patron_lookup.open
      barcode_found = verify {
        patron_lookup.clear_button.click
        patron_lookup.barcode_field.when_present.set(@patron[:barcode])
        patron_lookup.search_button.click
        patron_lookup.wait_for_page_to_load
        patron_lookup.text_in_results?(@patron[:barcode])
      }
      expect(barcode_found).to be_true
    end

    it 'by name' do
      patron_lookup.clear_button.click
      patron_lookup.wait_for_page_to_load
      patron_lookup.first_name_field.when_present.set(@patron[:first])
      patron_lookup.last_name_field.when_present.set(@patron[:last])
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      barcode_found = verify {patron_lookup.text_in_results?(@patron[:barcode])}
      expect(barcode_found).to be_true
    end

    it 'by email' do
      patron_lookup.clear_button.click
      patron_lookup.wait_for_page_to_load
      patron_lookup.email_address_field.when_present.set(@patron[:email])
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      barcode_found = verify {patron_lookup.text_in_results?(@patron[:barcode])}
      expect(barcode_found).to be_true
      patron_lookup.clear_button.click
    end
  end

  context 'is editable' do
    it 'after opening from search results' do
      patron_lookup.open
      patron_lookup.barcode_field.when_present.set(@patron[:barcode])
      patron_lookup.first_name_field.when_present.set(@patron[:first])
      patron_lookup.last_name_field.when_present.set(@patron[:last])
      patron_lookup.search_button.click
      patron_lookup.wait_for_page_to_load
      Watir::Wait.until { patron_lookup.text_in_results?(@patron[:barcode]) }
      patron_lookup.edit_by_text(@patron[:barcode]).when_present.click
      patron_opened_from_search = patron_page.wait_for_page_to_load
      expect(patron_opened_from_search).to be_true
    end

    it 'and takes a new borrower type' do
      patron_page.borrower_type_selector.when_present.select(@patron[:new_borrower_type])
      expect(patron_page.borrower_type_selector.selected?(@patron[:new_borrower_type])).to be_true
    end

    it 'and persists changes' do
      patron_page.submit_button.click
      expect(verify { patron_page.message.text =~ /success/ }).to be_true
    end

    it 'and verified via search' do
      patron_lookup.open
      patron_lookup.barcode_field.when_present.set(@patron[:barcode])
      patron_lookup.first_name_field.when_present.set(@patron[:first])
      patron_lookup.last_name_field.when_present.set(@patron[:last])
      patron_lookup.text_in_results?(@patron[:new_borrower_type])
    end
  end
end
