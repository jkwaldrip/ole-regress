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
    it 'by id' do
    end

    it 'by barcode' do
    end

    it 'by name' do
    end

    it 'by email' do
    end
  end
end
