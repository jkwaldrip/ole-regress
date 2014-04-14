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

shared_context 'Smoketest' do
  include OLE_QA::RegressionTest::Assertions
  
  let(:page)              {OLE_QA::Framework::Page.new(@ole,@ole.url)}
  let(:loan_page)         {OLE_QA::Framework::OLELS::Loan.new(@ole)}
  let(:return_page)       {OLE_QA::Framework::OLELS::Return.new(@ole)}
  let(:portal_page)       {OLE_QA::Framework::Page.new(@ole,@ole.url)}
  let(:docstore_page)     {OLE_QA::Framework::Page.new(@ole,@ole.docstore_url)}
  let(:bib_editor)        {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}
  let(:requisition)       {OLE_QA::Framework::OLEFS::Requisition.new(@ole)}
end
