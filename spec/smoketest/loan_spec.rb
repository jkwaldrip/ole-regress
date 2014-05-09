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

describe 'The OLE Loan Page' do
  include_context 'Smoketest'

  before :all do
    page                    = OLE_QA::Framework::Page.new(@ole,@ole.url)
    page.open
    page.login('dev2')
  end

  it 'opens via URL' do
    expect(loan_page.open).to be_true
  end

  it 'has a circulation desk selector' do
    desk_selector_present = loan_page.circulation_desk_selector.present?
    expect(desk_selector_present).to be_true
  end

  it 'has a patron barcode field' do
    patron_field_present = loan_page.patron_field.present?
    expect(patron_field_present).to be_true
  end

  it 'has a return button' do
    return_button_present = loan_page.return_button.present?
    expect(return_button_present).to be_true
  end
end
