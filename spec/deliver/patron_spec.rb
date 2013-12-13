require 'rspec'
require 'spec_helper.rb'

describe 'A Patron' do

  include_context 'New Patron'

  it 'has a new record' do
    patron_lookup.open
    patron_lookup.create_new.when_present.click
    patron_page.wait_for_page_to_load.should be_true
    new_patron(patron_page, @patron)
  end

  context 'is searchable' do
    it 'by barcode' do
      patron_lookup.open
      patron_lookup.barcode_field.when_present.set(@patron.barcode)
      patron_lookup.search_button.click
      patron_lookup.text_in_results?(@patron.barcode).should be_true
    end

    it 'by name' do
      patron_lookup.clear_button.click
      patron_lookup.first_name_field.when_present.set(@patron.first)
      patron_lookup.last_name_field.when_present.set(@patron.last)
      patron_lookup.search_button.click
      patron_lookup.text_in_results?(@patron.barcode).should be_true
    end

    it 'by email' do
      patron_lookup.clear_button.click
      patron_lookup.email_address_field.when_present.set(@patron.email)
      patron_lookup.search_button.click
      patron_lookup.text_in_results?(@patron.barcode).should be_true
      patron_lookup.clear_button.click
    end
  end
end
