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

describe 'The Order Record Batch Process' do

  include_context 'Batch Process'

  let(:load_summary_lookup)               {OLE_QA::Framework::OLEFS::Load_Summary_Lookup.new(@ole)}
  let(:load_report)                       {OLE_QA::Framework::OLEFS::Load_Report.new(@ole)}

  before :all do
    eocr       = OLE_QA::RegressionTest::EOCR.new
    @batch_job = OpenStruct.new(
        :job_name     => OLE_QA::Framework::String_Factory.alphanumeric(12),
        :mrc_file     => eocr.mrc_file,
        :edi_file     => eocr.edi_file,
        :file_name    => eocr.filename
    )
  end

  it 'opens a new batch process' do
    batch_process.open
  end

  it 'selects the Order Record Import profile' do
    batch_process.profile_search_icon.when_present.click
    profile_lookup.wait_for_page_to_load
    profile_lookup.profile_type_selector.when_present.select('Order Record Import')
    profile_lookup.search_button.when_present.click
    expect(Watir::Wait.until {profile_lookup.text_in_results('Test_Order_Import').present?}).to be_true
    profile_lookup.return_by_text('Test_Order_Import').click
  end

  it 'gives the job a name' do
    batch_process.name_field.when_present.set(@batch_job.job_name)
  end

  it 'selects the .mrc file' do
    batch_process.marc_file_field.when_present.set(@batch_job.mrc_file)
  end

  it 'selects the .edi file' do
    batch_process.edi_file_field.when_present.set(@batch_job.edi_file)
  end

  it 'runs the job' do
    batch_process.run_button.when_present.click
    batch_process.wait_for_page_to_load
    expect(batch_process.message.when_present.text).to match(/successfully saved/)
  end

  it 'opens the job details page' do
    expect(@ole.windows.count).to eq(2)
    @ole.windows[-1].close
  end

  # @note On the first run after a restart, it can take some time for the 'YBP' profile
  #   to show up in the load_profile_selector options list.
  #   - jkw, 2014/02/04
  it 'adds a YBP profile to load summary lookup' do
    expect(assert(120) {
      load_summary_lookup.open
      Watir::Wait.until { load_summary_lookup.load_profile_selector.include?('YBP') }
    }).to be_true
  end

  it 'generates a load summary' do
    expect(assert(60) {
      load_summary_lookup.user_id_field.when_present.clear
      load_summary_lookup.load_profile_selector.when_present.select('YBP')
      load_summary_lookup.filename_field.set(@batch_job.file_name)
      load_summary_lookup.search_button.click
      load_summary_lookup.wait_for_page_to_load
      load_summary_lookup.text_in_results?(@batch_job.file_name)
    }).to be_true
  end

  context 'generates a load report' do
    it 'with a document ID' do
      expect(load_summary_lookup.doc_link_by_text(@batch_job.file_name).present?).to be_true
      @batch_job.load_report_id = load_summary_lookup.doc_link_by_text(@batch_job.file_name).text.strip
      expect(@batch_job.load_report_id).to match(/\d+/)
    end

    # @note It can take some time for the record counts (total, success, failure) to be available
    #   on a load report after it is first opened.  The timeout needs to be generous, for now,
    #   to cut down on the number of failures due to a slow system after initial deployment.
    #   - jkw, 2014/02/04
    it 'with a record count' do
      url = load_report.lookup_url(@batch_job.load_report_id)
      expect(page_assert(url,180) {
        load_report.wait_for_page_to_load
        load_report.total_count =~ /\d+/
      }).to be_true
      @batch_job.record_count = load_report.total_count
    end

    it 'with a success count' do
      expect(load_report.success_count).to match(/\d+/)
      @batch_job.success_count = load_report.success_count
    end

    it 'with a failure count' do
      expect(load_report.failure_count).to match(/\d+/)
      @batch_job.failure_count = load_report.failure_count
    end


    # verify successes/failures exist
    # save no. of records, successes, failures to struct
    # verify links to bibs
    # verify links to POs
  end
end
