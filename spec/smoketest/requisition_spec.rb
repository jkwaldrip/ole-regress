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

describe 'An OLE Requisition' do
  include_context 'Smoketest'

  it 'opens via URL' do
    expect(requisition.open).to be_true
  end

  it 'has a document ID' do 
    expect(requisition.document_id.text).not_to be_empty
  end

  it 'has a status' do
    expect(requisition.document_status.text.strip).to eq('INITIATED')
  end

  it 'has a requisition status' do
    expect(requisition.document_type_status.text.strip).to eq('In Process')
  end

  it 'has a submit button' do
    expect(requisition.submit_button.present?).to be_true
  end

  it 'has a save button' do
    expect(requisition.save_button.present?).to be_true
  end

  it 'has a blanket approve button' do
    expect(requisition.approve_button.present?).to be_true
  end

  it 'has a cancel button' do
    expect(requisition.cancel_button.present?).to be_true
  end

  it 'can be cancelled' do
    requisition.cancel_button.click
    requisition.cancel_yes_button.wait_until_present
    requisition.cancel_yes_button.click
  end

  it 'returns to the portal when cancelled' do
    expect(@ole.browser.url).to eq(@ole.url + 'portal.do')
  end
end
