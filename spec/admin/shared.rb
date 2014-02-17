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
    location_lookup.login('admin').should be_true
  end

  def new_location(struct)
    location_lookup.open
    location_lookup.create_new.when_present.click
    location_page.wait_for_page_to_load
    results = create_location(location_page, struct)
    results[1].should be_nil
    results[0].should be_true
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
    location_lookup.text_in_results?(struct.code).should be_true
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
