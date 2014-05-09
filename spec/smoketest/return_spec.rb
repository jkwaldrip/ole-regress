#  Copyright 2005-2013 The Kuali Foundation
#
#  Licensed under the Educational Community License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#    http://www.opensource.org/licenses/ecl2.php
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require 'rspec'
require 'spec_helper.rb'

describe 'The OLE Return Page' do
  include_context 'Smoketest'

  it 'opens from the loan page' do
    loan_page.open
    loan_page.login('dev2')
    loan_page.open
    loan_page.return_button.when_present.click
    page_is_loaded = return_page.wait_for_page_to_load
    expect(page_is_loaded).to be_true
  end

  it 'has a checkin date field' do
    date_field_found = return_page.checkin_date_field.present?
    expect(date_field_found).to be_true
  end

  it 'has a checkin time field' do
    time_field_found = return_page.checkin_time_field.present?
    expect(time_field_found).to be_true
  end

  it 'has an item barcode field' do
    barcode_field_found = return_page.item_field.present?
    expect(barcode_field_found).to be_true
  end
end
