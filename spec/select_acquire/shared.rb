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

shared_context 'Create a Requisition' do
  
  let(:requisition)       { OLE_QA::Framework::OLEFS::Requisition.new(@ole) }
  let(:delivery)          { {:building => 'Wells Library', :room => '064'} }
  let(:vendor)            { 'YBP' }

  before :all do

    @info               = OpenStruct.new
    
    # Generate account info.
    account_ary         = OLE_QA::Framework::Account_Factory.select_account(:BL)
    object_ary          = OLE_QA::Framework::Account_Factory.select_object(:BL)

    @info.account       = { :chart    => 'BL',
                            :account  => account_ary[0],
                            :object   => object_ary[0],
                            :percent  => '100.00' }

    # Generate a price.
    @info.item          = { :price    => sprintf('%.2f',OLE_QA::Framework::String_Factory.numeric(2)) }

    # Generate invoice info.
    @info.invoice = {:date    => Time.now.strftime('%m/%d/%Y'),
                     :payment => 'Check',
                     :total   => @info.item[:price]}

  end
end
