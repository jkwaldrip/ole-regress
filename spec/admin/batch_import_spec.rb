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
  include_context 'New Batch Profile'

  let(:profile)            {OLE_QA::Framework::OLELS::Batch_Import_Profile.new(@ole)}
  let(:record)                    {MARC::Record.new}

  before :all do
    FileUtils::mkdir('data/uploads') unless File.directory?('data/uploads')
    @info                       = OpenStruct.new()
    @bib_record                 = OpenStruct.new(:key_str => OLE_QA::Framework::String_Factory.alphanumeric)
    @info.name                  = "QART-#{@bib_record.key_str}"
    @info.filename              = "#{@info.name}.mrc"
    @info.filepath              = File.expand_path('data/uploads/' + @info.filename)
    @writer                     = MARC::Writer.new("data/uploads/#{@info.filename}")
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

  context 'sets up an import profile' do
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
      profile_lookup.profile_name_field.when_present.set(@info.name)
    end

    it 'by profile type' do
      profile_lookup.profile_type_selector.select('Bib Import')
    end

    it 'and finds it' do
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      verify {profile_lookup.text_in_results(@info.name).present?}.should be_true
    end

    it 'and saves the profile ID' do
      @info.id = profile_lookup.id_by_text(@info.name).text
      @info.id.should =~ /\d+/
    end
  end
  
  context 'creates a batch job' do
    it 'with the new profile' do
      @info.batch_process_name = "RegressionTest-Import#{@info.id}"
      batch_process.open
      batch_process.name_field.when_present.set(@info.batch_process_name)
      batch_process.profile_search_icon.when_present.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.profile_name_field.when_present.set(@info.name)
      profile_lookup.profile_type_selector.when_present.select('Bib Import')
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.return_by_text(@info.name).when_present.click
      batch_process.wait_for_page_to_load
      batch_process.profile_name_field.when_present.value.should eq(@info.name)
    end

    it 'with a .mrc upload' do
      batch_process.input_file_field.when_present.set(@info.filepath)
      batch_process.input_file_field.value.should  eq(@info.filename)
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
        until verify(2) {job_details.text_in_results(@info.name).present? && job_details.job_status_by_text(@info.name).text.strip == 'COMPLETED'} do
          job_details.next_page.click
          job_details.wait_for_page_to_load
        end
      end
      job_details.job_status_by_text(@info.name).text.strip.should eq('COMPLETED')
    end

    it 'and opens the job details report' do
      job_details.job_report_by_text(@info.name).click
      @ole.windows.count.should eq(3)
      @ole.windows[-1].use
      job_report.wait_for_page_to_load
    end
  end

  context 'creates a job details report' do
    it 'with a job ID' do
      @info.job_id = job_report.job_id.when_present.text
      @info.job_id.should =~ /\d+/
    end

    it 'with a job name' do
      job_report.job_name.when_present.text.should eq(@info.batch_process_name)
    end

    it 'with a batch process id' do
      @info.batch_id = job_report.batch_process_id.text
      @info.batch_id.should =~ /\d+/
    end

    it 'with a username of admin' do
      job_report.user_name.text.should =~ /admin/
    end

    it 'with a records total count' do
      @info.records_total = job_report.total_records.text
      @info.records_total.should =~ /\d+/
    end

    it 'with a records processed count' do
      @info.records_processed = job_report.records_processed.text
      @info.records_processed.should =~ /\d+/
    end

    it 'with a successful records count' do
      @info.records_successful = job_report.success_records.text
      @info.records_successful.should=~ /\d+/
    end

    it 'with a failed records count' do
      @info.records_failed = job_report.failure_records.text
      @info.records_processed.should =~ /\d+/
    end

    it 'with a percent completed value of 100' do
      @info.percent_completed = job_report.percent_completed.text
      @info.percent_completed.should =~ /100/
    end

    it 'with a status of completed' do
      @info.status = job_report.status.text
      @info.status.should =~ /COMPLETED/
    end
  end

  context 'verifies' do
    it 'that the target string is found' do
      workbench.open
      set_field(workbench.document_type_selector,'Bibliographic')
      workbench.wait_for_page_to_load
      set_field(workbench.search_type_selector,'Search')
      workbench.wait_for_page_to_load
      set_field(workbench.search_line.search_field,@bib_record.key_str)
      workbench.search_line.search_scope_selector.when_present.select_value('phrase')
      workbench.search_line.search_scope_selector.value.should eq('phrase')
      set_field(workbench.search_line.field_selector,'Title')
      workbench.wait_for_page_to_load
      workbench.search_button.click
      workbench.wait_for_page_to_load
      workbench.title_in_results?("Record One #{@bib_record.key_str}").should be_true
      workbench.title_in_results?("Record Two #{@bib_record.key_str}").should be_true
      workbench.title_in_results?("Record Three #{@bib_record.key_str}").should be_true
    end

    it 'that there are three records in describe workbench' do
      results = workbench.b.tds(:xpath => "//table/tbody/tr/td[div/*[contains(text(),'#{@bib_record.key_str}')]]")
      results.count.should eq(3)
    end
  end
end