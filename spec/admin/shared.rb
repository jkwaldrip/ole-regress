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

shared_context 'Create Location' do
  
  include OLE_QA::RegressionTest::Location
  include OLE_QA::RegressionTest::Assertions

  let(:location_page)                   { OLE_QA::Framework::OLELS::Location.new(@ole) }
  let(:location_lookup)                 { OLE_QA::Framework::OLELS::Location_Lookup.new(@ole) }

  before :all do
    @location   = OpenStruct.new(OLE_QA::Framework::Metadata_Factory.new_location)
    @child_loc  = OpenStruct.new(OLE_QA::Framework::Metadata_Factory.new_location(2,@location.code))
  end

  def login(who = 'admin')
    location_lookup.open
    expect(location_lookup.login('admin')).to be_true
  end

  def new_location(struct)
    location_lookup.open
    location_lookup.create_new.when_present.click
    location_page.wait_for_page_to_load
    results = create_location(location_page, struct)
    expect(results[1]).to be_nil
    expect(results[0]).to be_true
  end

  def verify_location(struct)
    verify(90) {
      location_lookup.open
      location_lookup.wait_for_page_to_load
      location_lookup.location_id_field.when_present.set(struct.id) unless struct.id.nil?
      location_lookup.location_code_field.set(struct.code)
      location_lookup.location_name_field.set(struct.name)
      location_lookup.location_level_field.set(struct.level)
      location_lookup.search_button.click
      location_lookup.wait_for_page_to_load
      location_lookup.text_in_results?(struct.code)
    }
    expect(location_lookup.text_in_results?(struct.code)).to be_true
  end

end

shared_context 'Batch Process' do

  include OLE_QA::RegressionTest::Assertions

  let(:batch_profile)             {OLE_QA::Framework::OLELS::Batch_Profile.new(@ole)}
  let(:profile_lookup)            {OLE_QA::Framework::OLELS::Batch_Profile_Lookup.new(@ole)}
  let(:batch_type_lookup)         {OLE_QA::Framework::OLELS::Batch_Type_Lookup.new(@ole)}
  let(:batch_process)             {OLE_QA::Framework::OLELS::Batch_Process.new(@ole)}
  let(:job_details)               {OLE_QA::Framework::OLELS::Batch_Job_Details.new(@ole)}
  let(:job_report)                {OLE_QA::Framework::OLELS::Batch_Job_Report.new(@ole)}

end

shared_context 'New Batch Profile' do

  context 'creates a new profile' do
    it 'logged in as admin' do
      profile_lookup.open
      expect(profile_lookup.login('admin')).to be_true
      profile_lookup.open
    end

    it 'from the profile lookup' do
      profile_lookup.create_new.when_present.click
      profile.wait_for_page_to_load
    end

    it 'with a description' do
      profile.description_field.when_present.set("Regression Import #{@bib_record.key_str}")
      expect(profile.description_field.value).to  eq("Regression Import #{@bib_record.key_str}")
    end

    it 'with a name' do
      profile.batch_profile_name_field.when_present.set(@info.name)
      expect(profile.batch_profile_name_field.value).to  eq(@info.name)
    end
  end
end
