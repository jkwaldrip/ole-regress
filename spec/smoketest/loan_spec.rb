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
  let(:loan_page)           {OLE_QA::Framework::OLELS::Loan.new(@ole)}

  before :all do
    page                    = OLE_QA::Framework::Page.new(@ole,@ole.url)
    page.open
    page.login('dev2')
  end

  it 'opens via URL' do
    expect(loan_page.open).to be_true
  end

  it 'has a circulation desk selector' do
    expect(loan_page.circulation_desk_selector.present?).to be_true
  end

  it 'has a patron barcode field' do
    expect(loan_page.patron_field.present?).to be_true
  end

  it 'has a return button' do
    expect(loan_page.return_button.present?).to be_true
  end
end
