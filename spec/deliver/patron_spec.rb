require 'rspec'
require 'spec_helper.rb'

describe 'A Patron' do

  include_context 'New Patron'

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
