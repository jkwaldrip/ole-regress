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

describe 'The Batch Import process' do

  include_context 'Describe Workbench'
  include_context 'Batch Process'

  let(:profile)            {OLE_QA::Framework::OLELS::Batch_Import_Profile.new(@ole)}
  let(:describe_workbench)        {OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)}
  let(:record)                    {MARC::Record.new}

  before :all do
    FileUtils::mkdir('data/uploads') unless File.directory?('data/uploads')
    @import                       = OpenStruct.new()
    @bib_record                   = OpenStruct.new(:key_str => OLE_QA::Framework::String_Factory.alphanumeric)
    @import.name                  = "QART-#{@bib_record.key_str}"
    @import.filename              = "#{@import.name}.mrc"
    @import.filepath              = File.expand_path('data/uploads/' + @import.filename)
    @writer                       = MARC::Writer.new("data/uploads/#{@import.filename}")
  end

  context 'creates Marc record' do
    it 'one' do
      record.leader = '00168nam a2200073 a 4500'
      record.append(MARC::ControlField.new('008','140212s        xxu           000 0 eng d'))
      record.append(MARC::DataField.new('245','#','#',['a',"Record One #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'two' do
      record.leader = '00168nam a2200073 a 4500'
      record.append(MARC::ControlField.new('008','140212s        xxu           000 0 eng d'))
      record.append(MARC::DataField.new('245','#','#',['a',"Record Two #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'three' do
      record.leader = '00168nam a2200073 a 4500'
      record.append(MARC::ControlField.new('008','140212s        xxu           000 0 eng d'))
      record.append(MARC::DataField.new('245','#','#',['a',"Record Three #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'and saves it to a .mrc file' do
      @writer.close
    end
  end

  context 'creates a new profile' do
    it 'logged in as admin' do
      profile_lookup.open
      profile_lookup.login('admin').should be_true
      profile_lookup.open
    end

    it 'from the profile lookup' do
      profile_lookup.create_new.when_present.click
      profile.wait_for_page_to_load
    end

    it 'with a description' do
      profile.description_field.when_present.set("Regression Import #{@bib_record.key_str}")
      profile.description_field.value.should  eq("Regression Import #{@bib_record.key_str}")
    end

    it 'with a name' do
      profile.batch_profile_name_field.when_present.set(@import.name)
      profile.batch_profile_name_field.value.should  eq(@import.name)
    end
    
    it 'using the batch import process type' do
      profile.batch_process_type_icon.when_present.click
      batch_type_lookup.wait_for_page_to_load
      batch_type_lookup.name_field.when_present.set('Bib Import')
      batch_type_lookup.search_button.when_present.click
      verify {batch_type_lookup.text_in_results?('Bib Import')}
      batch_type_lookup.return_by_text('Bib Import').when_present.click
      profile.wait_for_page_to_load
      profile.batch_process_type_field.when_present.value.should eq('Bib Import')
    end

    it 'and approves it' do
      profile.approve_button.click
      profile.wait_for_page_to_load
      profile.messages.each do |message|
        message.when_present.text.should =~ /successfully/
      end
    end
  end

  context 'searches for the new profile' do
    it 'on the profile lookup page' do
      profile_lookup.open
    end

    it 'by name' do
      profile_lookup.profile_name_field.when_present.set(@import.name)
    end

    it 'by profile type' do
      profile_lookup.profile_type_selector.select('Bib Import')
    end

    it 'and finds it' do
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      verify {profile_lookup.text_in_results(@import.name).present?}.should be_true
    end

    it 'and saves the profile ID' do
      @import.id = profile_lookup.id_by_text(@import.name).text
      @import.id.should =~ /\d+/
    end
  end
  
  context 'creates a batch job' do
    it 'with the new profile' do
      @import.batch_process_name = "RegressionTest-Import#{@import.id}"
      batch_process.open
      batch_process.name_field.when_present.set(@import.batch_process_name)
      batch_process.profile_search_icon.when_present.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.profile_name_field.when_present.set(@import.name)
      profile_lookup.profile_type_selector.when_present.select('Bib Import')
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.return_by_text(@import.name).when_present.click
      batch_process.wait_for_page_to_load
      batch_process.profile_name_field.when_present.value.should eq(@import.name)
    end

    it 'with a .mrc upload' do
      batch_process.input_file_field.when_present.set(@import.filepath)
      batch_process.input_file_field.value.should  eq(@import.filename)
    end
  end

  context 'executes a batch job' do
    it 'running the batch process' do
      batch_process.run_button.click
      batch_process.wait_for_page_to_load
      batch_process.message.when_present.text.should =~ /successfully saved/
    end

    it 'and opens the job details window' do
      @ole.browser.windows.count.should eq(2)
      @ole.browser.windows[-1].use
      job_details.wait_for_page_to_load
    end

    it 'and finds the job in the job details window' do
      Timeout::timeout(300) do
        until verify(2) {job_details.text_in_results(@import.name).present? && job_details.job_status_by_text(@import.name).text.strip == 'COMPLETED'} do
          job_details.next_page.click
          job_details.wait_for_page_to_load
        end
      end
      job_details.job_status_by_text(@import.name).text.strip.should eq('COMPLETED')
    end

    it 'and opens the job details report' do
      job_details.job_report_by_text(@import.name).click
      @ole.windows.count.should eq(3)
      @ole.windows[-1].use
      job_report.wait_for_page_to_load
    end
  end

  context 'creates a job details report' do
    it 'with a job ID' do
      @import.job_id = job_report.job_id.when_present.text
      @import.job_id.should =~ /\d+/
    end

    it 'with a job name' do
      job_report.job_name.when_present.text.should eq(@import.batch_process_name)
    end

    it 'with a batch process id' do
      @import.batch_id = job_report.batch_process_id.text
      @import.batch_id.should =~ /\d+/
    end

    it 'with a username of admin' do
      job_report.user_name.text.should =~ /admin/
    end

    it 'with a records total count' do
      @import.records_total = job_report.total_records.text
      @import.records_total.should =~ /\d+/
    end

    it 'with a records processed count' do
      @import.records_processed = job_report.records_processed.text
      @import.records_processed.should =~ /\d+/
    end

    it 'with a successful records count' do
      @import.records_successful = job_report.success_records.text
      @import.records_successful.should=~ /\d+/
    end

    it 'with a failed records count' do
      @import.records_failed = job_report.failure_records.text
      @import.records_processed.should =~ /\d+/
    end

    it 'with a percent completed value of 100' do
      @import.percent_completed = job_report.percent_completed.text
      @import.percent_completed.should =~ /100/
    end

    it 'with a status of completed' do
      @import.status = job_report.status.text
      @import.status.should =~ /COMPLETED/
    end
  end

  context 'verifies' do
    it 'that the target string is found' do
      verify {
        describe_workbench.open
        bib_search(describe_workbench, 'Title', @bib_record.key_str) }
    end

    it 'that there are three records in describe workbench' do
      results = describe_workbench.b.tds(:xpath => "//table/tbody/tr/td[div/*[contains(text(),'#{@bib_record.key_str}')]]")
      results.count.should eq(3)
    end

  end

end