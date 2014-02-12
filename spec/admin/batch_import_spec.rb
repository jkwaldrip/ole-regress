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

  include OLE_QA::RegressionTest::Assertions

  let(:batch_profile)             {OLE_QA::Framework::OLELS::Batch_Profile.new(@ole)}
  let(:profile_lookup)            {OLE_QA::Framework::OLELS::Batch_Profile_Lookup.new(@ole)}
  let(:batch_type_lookup)         {OLE_QA::Framework::OLELS::Batch_Type_Lookup.new(@ole)}
  let(:job_details)               {OLE_QA::Framework::OLELS::Batch_Job_Details.new(@ole)}
  let(:job_report)                {OLE_QA::Framework::OLELS::Batch_Job_Report.new(@ole)}
  let(:import_profile)            {OLE_QA::Framework::OLELS::Batch_Import_Profile.new(@ole)}
  let(:describe_workbench)        {OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)}
  let(:record)                    {MARC::Record.new}

  before :all do
    FileUtils::mkdir('data/uploads') unless File.directory?('data/uploads')
    @import                       = OpenStruct.new()
    @bib_record                   = OpenStruct.new(:key_str => OLE_QA::Framework::String_Factory.alphanumeric)
    @import.name                  = "QART-#{@bib_record.key_str}"
    @import.filename              = "#{@import.name}.mrc"
    @writer                       = MARC::Writer.new("data/uploads/#{@import.filename}")
  end

  context 'creates Marc record' do
    it 'one' do
      record.append(MARC::DataField.new('245','#','#',['a',"Record One #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'two' do
      record.append(MARC::DataField.new('245','#','#',['a',"Record Two #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'three' do
      record.append(MARC::DataField.new('245','#','#',['a',"Record Three #{@bib_record.key_str}"]))
      @writer.write(record)
    end

    it 'and saves it to a .mrc file' do
      @writer.close
    end
  end
end