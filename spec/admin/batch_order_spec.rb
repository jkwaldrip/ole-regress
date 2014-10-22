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

describe 'The Order Record Batch Process', :xfer => true do

  include_context 'Batch Process'

  let(:load_summary_lookup)               {OLE_QA::Framework::OLEFS::Load_Summary_Lookup.new(@ole)}
  let(:load_report)                       {OLE_QA::Framework::OLEFS::Load_Report.new(@ole)}
  let(:order_profile)                     {OLE_QA::Framework::OLELS::Batch_Order_Profile.new(@ole)}
  let(:bib_profile)                       {OLE_QA::Framework::OLELS::Batch_Import_Profile.new(@ole)}

  before :all do
    eocr       = OLE_QA::RegressionTest::EOCR.new
    @batch_job = OpenStruct.new(
        :job_name     => OLE_QA::Framework::String_Factory.alphanumeric(12),
        :mrc_file     => eocr.mrc_file,
        :edi_file     => eocr.edi_file,
        :file_name    => eocr.filename
    )
  end

  context 'prepares the bib profile' do
    it 'Test Bib Import' do
      profile_lookup.open
      profile_lookup.profile_name_field.when_present.set('Test_Bib_Import')
      profile_lookup.search_button.when_present.click
      Watir::Wait.until {profile_lookup.text_in_results('Test_Bib_Import').present?}
      profile_lookup.edit_by_text('Test_Bib_Import').when_present.click
      bib_profile.wait_for_page_to_load
      bib_profile.description_field.when_present.set('Batch Order Test')
    end

    it 'with no bib matching' do
      bib_profile.match_section_toggle.click unless bib_profile.match_section_toggled?
      bib_profile.bib_no_match.when_present.click
      bib_profile.bib_no_match_add.when_present.click
    end

    it 'with no holdings matching' do
      bib_profile.match_holdings_toggle.click unless bib_profile.match_holdings_toggled?
      bib_profile.holdings_no_match.when_present.click
      bib_profile.holdings_add_unmatched.when_present.click
      bib_profile.holdings_keep_all.when_present.click
    end

    it 'with no item matching' do
      bib_profile.match_item_toggle.click unless bib_profile.match_item_toggled?
      bib_profile.item_no_match.when_present.click
      bib_profile.item_keep_all.when_present.click
    end

    it 'and submits the changes' do
      bib_profile.submit_button.when_present.click
      bib_profile.wait_for_page_to_load
      Watir::Wait.until {bib_profile.messages.count > 0}
      expect(bib_profile.messages[0].text.strip).to match(/Document was successfully submitted/i)
    end
  end
  
  context 'prepares the order profile' do
    it 'with Marc-only not set' do
      profile_lookup.open
      profile_lookup.profile_name_field.when_present.set('Test_Order_Import')
      profile_lookup.search_button.when_present.click
      profile_lookup.wait_for_page_to_load
      Watir::Wait.until {profile_lookup.text_in_results('Test_Order_Import').present?}
      profile_lookup.edit_by_text('Test_Order_Import').when_present.click
      order_profile.wait_for_page_to_load
      order_profile.description_field.when_present.set("AFT Batch Order Import #{Time.now.strftime('%D')}")
      order_profile.marc_only.when_present.click if order_profile.marc_only?
    end
  
    it 'using the Test Bib Import profile' do
      unless order_profile.bib_profile == 'Test_Bib_Import'
        order_profile.bib_profile_search.when_present.click
        profile_lookup.wait_for_page_to_load
        profile_lookup.profile_name_field.when_present.set('Test_Bib_Import')
        profile_lookup.search_button.when_present.click
        Watir::Wait.until {profile_lookup.text_in_results('Test_Bib_Import').present?}
        profile_lookup.return_by_text('Test_Bib_Import').when_present.click
        order_profile.wait_for_page_to_load
      end
    end
  
    it 'submits the profile' do
      order_profile.submit_button.when_present.click
      order_profile.wait_for_page_to_load
      Watir::Wait.until {order_profile.messages.count > 0}
      expect(order_profile.messages[0].text.strip).to match(/Document was successfully submitted/i)
    end
  end
 
  context 'runs the import' do
    it 'with the Order Record Import profile' do
      batch_process.open
      batch_process.profile_search_icon.when_present.click
      profile_lookup.wait_for_page_to_load
      profile_lookup.profile_type_selector.when_present.select('Order Record Import')
      profile_lookup.search_button.when_present.click
      Watir::Wait.until {profile_lookup.text_in_results('Test_Order_Import')}.present?
      profile_lookup.return_by_text('Test_Order_Import').when_present.click
    end
  
    it 'with a job name' do
      batch_process.wait_for_page_to_load
      set_field(batch_process.name_field,@batch_job.job_name)
    end
  
    it 'with the .mrc file' do
      batch_process.marc_file_field.when_present.set(@batch_job.mrc_file)
    end
  
    it 'with the .edi file' do
      batch_process.edi_file_field.when_present.set(@batch_job.edi_file)
    end
  
    it 'with the run now option' do
      batch_process.run_now_option.click unless batch_process.run_now_option.when_present.checked?
      batch_process.submit_button.when_present.click
      batch_process.wait_for_page_to_load
      message_text = batch_process.message.when_present.text
      expect(message_text).to match(/successfully saved/)
    end
  end

  context 'after running' do
    it 'appears in job details page' do
      expect(@ole.windows.count).to eq(2)
      @ole.windows[-1].close
    end
  
    it 'creates a load summary' do
      load_summary_lookup.open
      load_summary_lookup.wait_for_page_to_load
      load_summary_found = assert(60) {
        load_summary_lookup.user_id_field.when_present.clear
        load_summary_lookup.filename_field.set(@batch_job.file_name)
        load_summary_lookup.date_from_field.set(Time.now.strftime('%D'))
        load_summary_lookup.search_button.click
        load_summary_lookup.wait_for_page_to_load
        load_summary_lookup.text_in_results?(@batch_job.file_name)
      }
      expect(load_summary_found).to be_true
    end
  end
  
  context 'generates a load report' do
    it 'with a document ID' do
      doc_id_found = load_summary_lookup.doc_link_by_text(@batch_job.file_name).present?
      expect(doc_id_found).to be_true
      @batch_job.load_report_id = load_summary_lookup.doc_link_by_text(@batch_job.file_name).text.strip
      expect(@batch_job.load_report_id).to match(/\d+/)
    end

    # @note It can take some time for the record counts (total, success, failure) to be available
    #   on a load report after it is first opened.  The timeout needs to be generous, for now,
    #   to cut down on the number of failures due to a slow system after initial deployment.
    #   - jkw, 2014/02/04
    it 'with a record count' do
      url = load_report.lookup_url(@batch_job.load_report_id)
      record_count_found = page_assert(url,180) {
        load_report.wait_for_page_to_load
        load_report.total_count =~ /\d+/
      }
      expect(record_count_found).to be_true
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
