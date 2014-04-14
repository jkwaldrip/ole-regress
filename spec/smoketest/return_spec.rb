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
    expect(return_page.wait_for_page_to_load).to be_true
  end

  it 'has a checkin date field' do
    expect(return_page.checkin_date_field.present?).to be_true
  end

  it 'has a checkin time field' do
    expect(return_page.checkin_time_field.present?).to be_true
  end

  it 'has an item barcode field' do
    expect(return_page.item_field.present?).to be_true
  end
end
