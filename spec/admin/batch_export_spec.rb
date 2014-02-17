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

  include OLE_QA::RegressionTest::MarcEditor

  include_context 'Batch Process'

  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}
  let(:export_profile)            {OLE_QA::Framework::OLELS::Batch_Export_Profile.new(@ole)}

  before :all do
    FileUtils::mkdir('data/downloads') unless File.directory?('data/downloads')
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
    @export.name                  = "QART-#{@bib_record.key_str}"
    @export.filename              = "#{@export.name}.mrc"
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

  context 'creates a new profile' do
    it 'logged in as admin' do
      profile_lookup.open
      profile_lookup.login('admin').should be_true
      profile_lookup.open
    end

    it 'from the profile lookup' do
      profile_lookup.create_new.when_present.click
      export_profile.wait_for_page_to_load
    end

    it 'with a description' do
      export_profile.description_field.when_present.set("Regression Export #{@bib_record.key_str}")
      export_profile.description_field.value.should  eq("Regression Export #{@bib_record.key_str}")
    end

    it 'with a name' do
      export_profile.batch_profile_name_field.when_present.set(@export.name)
      export_profile.batch_profile_name_field.value.should  eq(@export.name)
    end

    it 'using the batch export process type' do
      export_profile.batch_process_type_icon.when_present.click
      batch_type_lookup.wait_for_page_to_load
      batch_type_lookup.name_field.when_present.set('Batch Export')
      batch_type_lookup.search_button.when_present.click
      verify {batch_type_lookup.text_in_results?('Batch Export')}
      batch_type_lookup.return_by_text('Batch Export').when_present.click
      export_profile.wait_for_page_to_load
      export_profile.batch_process_type_field.when_present.value.should eq('Batch Export')
    end

    it 'with a description' do
      export_profile.description_field.when_present.set("Regression Export #{@bib_record.key_str}")
      export_profile.description_field.value.should  eq("Regression Export #{@bib_record.key_str}")
    end

    it 'with a name' do
      export_profile.batch_profile_name_field.when_present.set("QART-#{@bib_record.key_str}")
      export_profile.batch_profile_name_field.value.should  eq("QART-#{@bib_record.key_str}")
    end

    it 'with filter criteria' do
      export_profile.export_scope_selector.when_present.select('Filter')
      export_profile.filter_criteria_toggle.click
      export_profile.filter_field_name_field.when_present.set('245 $a')
      export_profile.filter_field_value_field.when_present.set(@bib_record.key_str)
      export_profile.add_filter_line_button.click
      export_profile.filter_line.name.when_present.text.should eq('245 $a')
      export_profile.filter_line.name_readonly.when_present.text.should eq('245 $a')
      export_profile.filter_line.value.when_present.text.should eq(@bib_record.key_str)
    end

    it 'and approves it' do
      export_profile.approve_button.click
      export_profile.wait_for_page_to_load
      export_profile.messages.each do |message|
        message.when_present.text.should =~ /successfully/
      end
    end
  end

  context 'searches for the new profile' do
    it 'on the profile lookup page' do
      profile_lookup.open
    end

    it 'by name' do
      profile_lookup.profile_name_field.when_present.set(@export.name)
    end

    it 'by profile type' do
      profile_lookup.profile_type_selector.select('Batch Export')
    end

    it 'and finds it' do
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      verify {profile_lookup.text_in_results(@export.name).present?}.should be_true
    end

    it 'and saves the profile ID' do
      @export.id = profile_lookup.id_by_text(@export.name).text
      @export.id.should =~ /\d+/
    end
  end

  context 'creates a batch job' do
    it 'with the new profile' do
      @export.batch_process_name = "RegressionTest-Export#{@export.id}"
      batch_process.open
      batch_process.name_field.when_present.set(@export.batch_process_name)
      batch_process.profile_search_icon.when_present.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.profile_name_field.when_present.set(@export.name)
      profile_lookup.profile_type_selector.when_present.select('Batch Export')
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.return_by_text(@export.name).when_present.click
      batch_process.wait_for_page_to_load
      batch_process.profile_name_field.when_present.value.should eq(@export.name)
    end

    it 'with an output filename' do
      batch_process.output_file_field.when_present.set(@export.filename)
      batch_process.output_file_field.value.should eq(@export.filename)
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
        until verify(2) {job_details.text_in_results(@export.name).present? && job_details.job_status_by_text(@export.name).text.strip == 'COMPLETED'} do
          job_details.next_page.click
          job_details.wait_for_page_to_load
        end
      end
      job_details.job_status_by_text(@export.name).text.strip.should eq('COMPLETED')
    end

    it 'and opens the job details report' do
      job_details.job_report_by_text(@export.name).click
      @ole.windows.count.should eq(3)
      @ole.windows[-1].use
      job_report.wait_for_page_to_load
    end
  end

  context 'creates a job details report' do
    it 'with a job ID' do
      @export.job_id = job_report.job_id.when_present.text
      @export.job_id.should =~ /\d+/
    end

    it 'with a job name' do
      job_report.job_name.when_present.text.should eq(@export.batch_process_name)
    end

    it 'with a batch process id' do
      @export.batch_id = job_report.batch_process_id.text
      @export.batch_id.should =~ /\d+/
    end

    it 'with a username of admin' do
      job_report.user_name.text.should =~ /admin/
    end

    it 'with a records total count' do
      @export.records_total = job_report.total_records.text
      @export.records_total.should =~ /\d+/
    end

    it 'with a records processed count' do
      @export.records_processed = job_report.records_processed.text
      @export.records_processed.should =~ /\d+/
    end

    it 'with a successful records count' do
      @export.records_successful = job_report.success_records.text
      @export.records_successful.should=~ /\d+/
    end

    it 'with a failed records count' do
      @export.records_failed = job_report.failure_records.text
      @export.records_processed.should =~ /\d+/
    end

    it 'with a percent completed value of 100' do
      @export.percent_completed = job_report.percent_completed.text
      @export.percent_completed.should =~ /100/
    end

    it 'with a status of completed' do
      @export.status = job_report.status.text
      @export.status.should =~ /COMPLETED/
    end
  end

  context 'exports a .mrc file' do
    it 'and downloads it' do
      @export.mrc_filepath = 'data/downloads/' + @export.filename
      @export.mrc_url      = "#{@ole.url}home/#{@export.filename}/#{@export.job_id}/#{@export.filename}"
      open(@export.mrc_filepath,'wb') do |file|
        file << open(@export.mrc_url).read
      end
    end

    it 'and verifies it' do
      File.exists?(@export.mrc_filepath).should be_true
    end

    it 'with 3 records' do
      reader = MARC::Reader.new(@export.mrc_filepath)
      @export.records = []
      reader.each {|record| @export.records << record}
      @export.records.count.should eq(3)
    end

    it 'with the target value in each title' do
      @export.records.each do |record|
        record.each_by_tag('245') do |datafield|
          datafield.value.should =~ /#{@bib_record.key_str}/
        end
      end
    end
  end
end