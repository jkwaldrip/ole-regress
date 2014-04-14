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

describe 'The OLE bib editor' do
  include_context 'Smoketest'

  it 'opens via URL' do
    expect(bib_editor.open).to be_true
  end

  it 'displays a message for a blank bib record' do
    bib_editor.message.wait_until_present
    message = bib_editor.message.text
    expect(message =~ /enter details for new [Bb]ib record/).to be_true
  end

  it 'has a blank Marc data line' do
    field = bib_editor.data_line.data_field
    field.wait_until_present
    expect(field.value.empty?).to be_true
  end
end
