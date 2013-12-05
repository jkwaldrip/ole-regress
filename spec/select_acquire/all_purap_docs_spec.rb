require 'rspec'
require 'spec_helper.rb'

describe 'The PURAP Workflow' do
  include OLE_QA::RegressionTest::PURAP::Requisition
  include OLE_QA::RegressionTest::Assertions
  include_context 'Create a Marc Record'
  include_context 'Create a Requisition'

  let(:purchase_order)          { OLE_QA::Framework::OLEFS::Purchase_Order.new(@ole) }
  let(:receiving)               { OLE_QA::Framework::OLEFS::Receiving_Document.new(@ole) }
  let(:invoice)                 { OLE_QA::Framework::OLEFS::Invoice.new(@ole) }

  it 'opens a new requisition' do
    requisition.open
  end

  it 'selects a delivery location' do
    results = set_delivery(requisition, delivery)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'selects a vendor' do
    results = set_vendor(requisition, vendor)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'selects a new bib record for a line item' do
    results = set_new_bib(requisition)
    results[:error].should be_nil
    results[:pass?].should be_true
  end
  
  it 'enters the new bib' do
    new_bib_record
    close_editor
  end
  
  it 'returns to the requisition' do
    @ole.browser.windows[-1].close if @ole.browser.windows.count > 1
    @ole.browser.windows[0].use
    requisition.wait_for_page_to_load
  end
  
  it 'gives a list price' do
    requisition.list_price_field.when_present.set(@info.item[:price])
  end

  it 'gives a location' do
    requisition.location_selector.when_present.select('B-EDUC/BED-STACKS')
  end

  it 'sets the number of copies' do
    requisition.copies_field.when_present.set('1')
  end

  it 'adds the line item' do
    requisition.add_button.when_present.click
    requisition.wait_for_page_to_load
  end

  it 'has consistent data on a new line item' do
    requisition.line_item.line_number = 1
    requisition.line_item.list_price_field.when_present.value.should    eq(@info.item[:price])
    requisition.line_item.location_selector.when_present.value.should   eq('B-EDUC/BED-STACKS')
    requisition.line_item.copies_field.when_present.value.should        eq('1')
  end
  
  it 'adds an account to the new line' do
    results = set_acct(requisition, @info.account)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'has consistent data on a new accounting line' do
    requisition.line_item.accounting_line.chart_selector.selected?(@info.account[:chart]).should  be_true
    requisition.line_item.accounting_line.account_number_field.value.should   eq(@info.account[:account])
    requisition.line_item.accounting_line.object_field.value.should           eq(@info.account[:object])
    requisition.line_item.accounting_line.percent_field.value.should          eq(@info.account[:percent])
  end

  it 'can submit the requisition' do
    requisition.submit_button.click
    requisition.wait_for_page_to_load
    requisition.generic_message.wait_until_present
    requisition.submit_message.present?.should be_true
  end

  it 'can get a requisition ID' do
    requisition.document_id.present?.should be_true
    @info.requisition             = Hash.new
    @info.requisition[:id]        = requisition.document_id.text.strip
    @info.requisition[:url]       = requisition.lookup_url(@info.requisition[:id])
  end
  
  it 'waits for the requisition status to be Closed' do
    page_assert(@info.requisition[:url])   { requisition.wait_for_page_to_load
                                             requisition.document_type_status.text.include?('Closed') }.should be_true
  end

  it 'should have a valid PO number' do
    page_assert(@info.requisition[:url])   { requisition.wait_for_page_to_load
                          requisition.view_related_tab_toggle.click unless requisition.view_related_po_link.present?
                          requisition.view_related_po_link.wait_until_present
                          requisition.view_related_po_link.text =~ /[0-9]+/ }.should be_true
    @info.po        = Hash.new
    @info.po[:id]   = requisition.view_related_po_link.text.strip
    @info.po[:url]  = requisition.view_related_po_link.href
  end

  it 'opens the PO' do
    @ole.browser.goto(@info.po[:url])
    purchase_order.wait_for_page_to_load.should be_true
  end

  it 'retrieves a PO number' do
    @info.po[:po_id] = purchase_order.document_type_id.text.strip
    @info.po[:po_id].should =~ /[0-9]+/
  end

  it 'has appropriate PO statuses' do
    purchase_order.document_status.text.strip.should        match(/FINAL/)
    purchase_order.document_type_status.text.strip.should   match(/Open/)
  end

  it 'can receive the PO' do
    purchase_order.receiving_button.when_present.click
  end

  it 'opens a receiving document' do
    receiving.wait_for_page_to_load.should be_true
  end

  it 'receives the line item' do
    receiving.receiving_line.receive_button.when_present.click
  end

  it 'submits the receiving document' do
    receiving.submit_button.click
    receiving.wait_for_page_to_load
    receiving.submit_message.present?.should be_true
  end

  it 'opens a new invoice' do
    invoice.open
    invoice.wait_for_page_to_load
  end

  it 'selects a vendor' do
    invoice.vendor_selector.when_present.select(/#{vendor}/)
    invoice.wait_for_page_to_load
  end

  it 'sets invoice information' do
    invoice.invoice_date_field.when_present.set(@info.invoice[:date])
    invoice.vendor_invoice_amt_field.when_present.set(@info.invoice[:total])
    invoice.payment_method_selector.when_present.select(@info.invoice[:payment])
  end

  it 'selects the purchase order' do
    invoice.po_number_field.when_present.set(@info.po[:id] + "\n")
    invoice.wait_for_page_to_load
  end

  it 'adds the purchase order' do
    invoice.po_line.add_button.when_present.click
    invoice.current_items_line.po_number.when_present.text.strip.should eq(@info.po[:id])
  end

  it 'saves the invoice' do
    @info.invoice[:id]  = invoice.document_id.when_present.text.strip
    @info.invoice[:url] = invoice.lookup_url(@info.invoice[:id])
    invoice.save_button.click
    invoice.wait_for_page_to_load
    invoice.document_status.when_present.text.strip.should match('SAVED')
  end

  it 'approves the invoice' do
    invoice.approve_button.when_present.click
  end

  it 'waits for the invoice to be department-approved' do
    page_assert(@info.invoice[:url])    { invoice.document_type_status.when_present.text.strip.include?('Department-Approved') }.should be_true
  end
end
