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

shared_context 'Create a Marc Record' do
  
  include OLE_QA::RegressionTest::MarcEditor
  
  before :all do
    @marc_record                = OpenStruct.new
    @marc_record.bib_info       = [
                                      {:tag             => '100',
                                      :value            => '|a' + OLE_QA::Framework::String_Factory.alphanumeric},
                                      {:tag             => '245',
                                      :value            => '|a' + OLE_QA::Framework::String_Factory.alphanumeric}
    ]
    @marc_record.instance_info  = {
                                      :location         => 'B-EDUC/BED-STACKS',
                                      :call_number      => OLE_QA::Framework::Bib_Factory.call_number,
                                      :call_number_type => 'LCC'
    }
    @marc_record.item_info      = {
                                      :item_type        => 'Book',
                                      :item_status      => 'Available',
                                      :barcode          => OLE_QA::Framework::Bib_Factory.barcode
    }
  end

  let(:bib_editor)        { OLE_QA::Framework::OLELS::Bib_Editor.new(@ole) }
  let(:instance_editor)   { OLE_QA::Framework::OLELS::Instance_Editor.new(@ole) }
  let(:item_editor)       { OLE_QA::Framework::OLELS::Item_Editor.new(@ole) }

  it 'opens the Marc editor' do
    bib_editor.open
  end

  it 'creates a new bib record' do
    results = create_bib(bib_editor, @marc_record.bib_info)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'creates a new instance record' do
    results = create_instance(instance_editor, @marc_record.instance_info)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'creates a new item record' do
    results = create_item(item_editor, @marc_record.item_info)
    results[:error].should be_nil
    results[:pass?].should be_true
  end
end
