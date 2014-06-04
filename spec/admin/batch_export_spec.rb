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

describe 'The Batch Export process', :xfer => true do

  include OLE_QA::RegressionTest::MarcEditor

  include_context 'Batch Process'
  include_context 'New Batch Profile'

  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}
  let(:profile)            {OLE_QA::Framework::OLELS::Batch_Export_Profile.new(@ole)}

  before :all do
    FileUtils::mkdir('data/downloads') unless File.directory?('data/downloads')
    @info                         = OpenStruct.new()
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
    @info.name                    = "QART-#{@bib_record.key_str}"
    @info.filename                = "#{@info.name}.mrc"
  end

  context 'sets up an export profile' do
    it 'using the batch export process type' do
      profile.batch_process_type_icon.when_present.click
      batch_type_lookup.wait_for_page_to_load
      batch_type_lookup.name_field.when_present.set('Batch Export')
      batch_type_lookup.search_button.when_present.click
      verify {batch_type_lookup.text_in_results?('Batch Export')}
      batch_type_lookup.return_by_text('Batch Export').when_present.click
      @ole.browser.iframe(:id => 'iframeportlet').wait_until_present
      batch_process_type = profile.batch_process_type_field.when_present.value
      expect(batch_process_type).to eq('Batch Export')
    end

    it 'with filter criteria' do
      profile.export_scope_selector.when_present.select('Filter')
      profile.filter_criteria_toggle.click
      profile.filter_field_name_field.when_present.set('245 $a')
      profile.filter_field_value_field.when_present.set(@bib_record.key_str)
      profile.add_filter_line_button.click
      expect(profile.filter_line.name.when_present.text).to eq('245 $a')
      expect(profile.filter_line.name_readonly.when_present.text).to eq('245 $a')
      expect(profile.filter_line.value.when_present.text).to eq(@bib_record.key_str)
    end

    it 'and approves it' do
      profile.approve_button.click
      profile.wait_for_page_to_load
      profile.messages.each do |message|
        message_text = message.when_present.text
        expect(message_text).to match(/successfully/)
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
      profile_lookup.profile_type_selector.select('Batch Export')
    end

    it 'and finds it' do
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      profile_found = verify {profile_lookup.text_in_results(@info.name).present?}
      expect(profile_found).to be_true
    end

    it 'and saves the profile ID' do
      @info.id = profile_lookup.id_by_text(@info.name).text
      profile_id = @info.id
      expect(profile_id).to match(/\d+/)
    end
  end

  context 'creates target record' do
    it 'one' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.one)
      expect(results[:message]).to match(/success/)
    end

    it 'two' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.two)
      expect(results[:message]).to match(/success/)
    end

    it 'three' do
      bib_editor.open
      results = create_bib(bib_editor, @bib_record.three)
      expect(results[:message]).to match(/success/)
    end
  end

  context 'creates a batch job' do
    it 'with the new profile' do
      @info.batch_process_name = "RegressionTest-Export#{@info.id}"
      batch_process.open
      batch_process.name_field.when_present.set(@info.batch_process_name)
      batch_process.profile_search_icon.when_present.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.profile_name_field.when_present.set(@info.name)
      profile_lookup.profile_type_selector.when_present.select('Batch Export')
      profile_lookup.search_button.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.return_by_text(@info.name).when_present.click
      batch_process.wait_for_page_to_load
      profile_name = batch_process.profile_name_field.when_present.value
      expect(profile_name).to eq(@info.name)
    end

    it 'with an output filename' do
      batch_process.output_file_field.when_present.set(@info.filename)
      output_file_name = batch_process.output_file_field.value
      expect(output_file_name).to eq(@info.filename)
    end
  end

  context 'executes a batch job' do
    it 'running the batch process' do
      batch_process.run_button.click
      batch_process.wait_for_page_to_load
      message_text = batch_process.message.when_present.text 
      expect(message_text).to match(/successfully saved/)
    end

    it 'and opens the job details window' do
      expect(@ole.browser.windows.count).to eq(2)
      @ole.browser.windows[-1].use
      job_details.wait_for_page_to_load
    end

    it 'and finds the job in the job details window' do
      job_completed = page_assert(job_details.url,300) {
        job_details.next_page.click unless job_details.text_in_results(@info.name).present?
        job_details.job_status_by_text
        job_details.job_status_by_text(@info.name).text.strip == 'COMPLETED' }
      expect(job_completed).to be_true
    end

    it 'and opens the job details report' do
      job_details.job_report_by_text(@info.name).click
      expect(@ole.windows.count).to eq(3)
      @ole.windows[-1].use
      job_report.wait_for_page_to_load
    end
  end

  context 'creates a job details report' do
    it 'with a job ID' do
      @info.job_id = job_report.job_id.when_present.text
      expect(@info.job_id).to match(/\d+/)
    end

    it 'with a job name' do
      job_name = job_report.job_name.when_present.text
      expect(job_name).to eq(@info.batch_process_name)
    end

    it 'with a batch process id' do
      @info.batch_id = job_report.batch_process_id.text
      expect(@info.batch_id).to match(/\d+/)
    end

    it 'with a username of admin' do
      username = job_report.user_name.text
      expect(username).to match(/admin/)
    end

    it 'with a records total count' do
      @info.records_total = job_report.total_records.text
      expect(@info.records_total).to match(/\d+/)
    end

    it 'with a records processed count' do
      @info.records_processed = job_report.records_processed.text
      expect(@info.records_processed).to match(/\d+/)
    end

    it 'with a successful records count' do
      @info.records_successful = job_report.success_records.text
      expect(@info.records_successful).to match(/\d+/)
    end

    it 'with a failed records count' do
      @info.records_failed = job_report.failure_records.text
      expect(@info.records_processed).to match(/\d+/)
    end

    it 'with a percent completed value of 100' do
      @info.percent_completed = job_report.percent_completed.text
      expect(@info.percent_completed).to match(/100/)
    end

    it 'with a status of completed' do
      @info.status = job_report.status.text
      expect(@info.status).to match(/COMPLETED/)
    end

    it 'with a download link' do
      download_link       = job_report.view_export_file
      expect(download_link.present?).to be_true
      @info.mrc_url       = download_link.href
    end
  end

  context 'exports a .mrc file' do
    it 'and downloads it' do
      @info.mrc_filepath  = 'data/downloads/' + @info.filename
      open(@info.mrc_filepath,'wb') do |file|
        file << open(@info.mrc_url).read
      end
    end

    it 'and verifies it' do
      file_exists = File.exists?(@info.mrc_filepath)
      expect(file_exists).to be_true
    end

    it 'with 3 records' do
      reader = MARC::Reader.new(@info.mrc_filepath)
      @info.records = []
      reader.each {|record| @info.records << record}
      expect(@info.records.count).to eq(3)
    end

    it 'with the target value in each title' do
      @info.records.each do |record|
        record.each_by_tag('245') do |datafield|
          title_value = datafield.value
          expect(title_value).to match(/#{@bib_record.key_str}/)
        end
      end
    end
  end
end
