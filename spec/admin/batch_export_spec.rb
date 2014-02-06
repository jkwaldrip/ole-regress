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

describe 'The Batch Export process' do

  include OLE_QA::RegressionTest::Assertions
  include OLE_QA::RegressionTest::MarcEditor

  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}
  let(:batch_profile)             {OLE_QA::Framework::OLELS::Batch_Profile.new(@ole)}
  let(:profile_lookup)            {OLE_QA::Framework::OLELS::Batch_Profile_Lookup.new(@ole)}
  let(:export_profile)            {OLE_QA::Framework::OLELS::Batch_Export_Profile.new(@ole)}
  let(:batch_type_lookup)         {OLE_QA::Framework::OLELS::Batch_Type_Lookup.new(@ole)}

  before :all do
    @export                       = OpenStruct.new()
    @bib_record                   = OpenStruct.new(:key_str => OLE_QA::Framework::String_Factory.alphanumeric)
    @bib_record.one               = [
                                      {:tag     => '245',
                                       :value   => "|aRecord One #{@bib_record.key_str}"}
    ]
    @bib_record.two               = [
                                      {:tag     => '245',
                                      :value    => "|aRecord Two #{@bib_record.key_str}"}
    ]
    @bib_record.three             = [
                                      {:tag     => '245',
                                      :value    => "|aRecord Three #{@bib_record.key_str}"}
    ]
  end

  context 'creates target record' do

    it 'one' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.one)
      results[:message].should =~ /success/
    end

    it 'two' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.two)
      results[:message].should =~ /success/
    end

    it 'three' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.three)
      results[:message].should =~ /success/
    end
  end

  context 'creates with a new profile' do

    it 'logged in as admin' do
      profile_lookup.open
      profile_lookup.login('admin').should be_true
      profile_lookup.open
    end

    it 'from the profile lookup' do
      profile_lookup.create_new.when_present.click
      export_profile.wait_for_page_to_load
    end

    it 'using the batch export process type' do
      export_profile.batch_process_type_icon.when_present.click
      batch_type_lookup.wait_for_page_to_load
      batch_type_lookup.name_field.when_present.set('Batch Export')
      batch_type_lookup.search_button.when_present.click
      verify {batch_type_lookup.text_in_results('Batch Export')}
      batch_type_lookup.return_by_text('Batch Export').when_present.click
      export_profile.wait_for_page_to_load
      export_profile.batch_process_type_field.when_present.value.should eq('Batch Export')
    end

    it 'with a description' do
      export_profile.description_field.when_present.set("QA Regression Test #{@bib_record.key_str}")
      export_profile.description_field.value.should  eq("QA Regression Test #{@bib_record.key_str}")
    end

    it 'with a name' do
      export_profile.batch_profile_name_field.when_present.set("QART-#{@bib_record.key_str}")
      export_profile.batch_profile_name_field.value.should  eq("QART-#{@bib_record.key_str}")
    end

    it 'with filter criteria' do
      export_profile.filter_criteria_toggle.click
      export_profile.filter_field_name_field.when_present.set('245 $a')
      export_profile.filter_field_value_field.when_present.set(@bib_record.key_str)
      export_profile.add_filter_line_button.click
      export_profile.filter_line.name.text.should eq('245 $a')
      export_profile.filter_line.name_readonly.text.should eq('245 $a')
      export_profile.filter_line.value.text.should eq(@bib_record.key_str)
    end

    it 'and approves it' do
      export_profile.approve_button.click
      export_profile.wait_for_page_to_load
      export_profile.messages.each do |message|
        message.when_present.text.should =~ /successfully/
      end
    end

  end
end