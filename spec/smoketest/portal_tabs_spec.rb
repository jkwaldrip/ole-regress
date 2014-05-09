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

describe 'The OLE Portal' do
  include_context 'Smoketest'

  it 'opens in a browser' do
    expect(page.open).to be_true
  end

  it 'has an admin tab' do
    link = page.b.link(:text => /[Aa]dmin/)
    admin_tab_found = link.present?
    expect(admin_tab_found).to be_true
    link.click
  end

  it 'has a maintenance tab' do
    link = page.b.link(:text => /[Mm]aintenance/)
    maintenance_tab_found = link.present?
    expect(maintenance_tab_found).to be_true
    link.click
  end

  it 'has a select/acquire tab' do
    link = page.b.link(:text => /[Ss]elect.{1}[Aa]cquire/)
    select_acquire_tab_found = link.present?
    expect(select_acquire_tab_found).to be_true
    link.click
  end

  it 'has a describe tab' do
    link = page.b.link(:text => /[Dd]escribe/)
    describe_tab_found = link.present?
    expect(describe_tab_found).to be_true
    link.click
  end

  it 'has a deliver tab' do
    link = page.b.link(:text => /[Dd]eliver/)
    deliver_tab_found = link.present?
    expect(deliver_tab_found).to be_true
    link.click
  end
end
