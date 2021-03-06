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
    expect(results[:error]).to be_nil
    expect(results[:pass?]).to be_true
  end

  it 'selects a vendor' do
    results = set_vendor(requisition, vendor)
    expect(results[:error]).to be_nil
    expect(results[:pass?]).to be_true
  end

  it 'selects a new bib record for a line item' do
    results = set_new_bib(requisition)
    expect(results[:error]).to be_nil
    expect(results[:pass?]).to be_true
  end
  
  it 'enters the new bib' do
    new_bib_record
    close_editor
  end
  
  it 'returns to the requisition' do
    @ole.browser.windows[-1].close if @ole.browser.windows.count > 1
    @ole.browser.alert.ok if @ole.browser.alert.present?
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
    list_price_value              = requisition.line_item.list_price_field.when_present.value
    location_value                = requisition.line_item.location_selector.when_present.value
    copies_value                  = requisition.line_item.copies_field.when_present.value
    expect(list_price_value).to   eq(@info.item[:price])
    expect(location_value).to     eq('B-EDUC/BED-STACKS')
    expect(copies_value).to       eq('1')
  end
  
  it 'adds an account to the new line' do
    results = set_acct(requisition, @info.account)
    expect(results[:error]).to be_nil
    expect(results[:pass?]).to be_true
  end

  it 'has consistent data on a new accounting line' do
    chart_selected                = requisition.line_item.accounting_line.chart_selector.selected?(@info.account[:chart])
    account_num_value             = requisition.line_item.accounting_line.account_number_field.value
    object_code_value             = requisition.line_item.accounting_line.object_field.value
    percent_value                 = requisition.line_item.accounting_line.percent_field.value
    expect(chart_selected).to     be_true
    expect(account_num_value).to  eq(@info.account[:account])
    expect(object_code_value).to  eq(@info.account[:object])
    expect(percent_value).to      eq(@info.account[:percent])
  end

  it 'can submit the requisition' do
    requisition.submit_button.click
    requisition.wait_for_page_to_load
    requisition.generic_message.wait_until_present
    success_message_given         = requisition.submit_message.present?
    expect(success_message_given).to be_true
  end

  it 'can get a requisition ID' do
    id_found                      = requisition.document_id.present?
    expect(id_found).to be_true
    @info.requisition             = Hash.new
    @info.requisition[:id]        = requisition.document_id.text.strip
    @info.requisition[:url]       = requisition.lookup_url(@info.requisition[:id])
  end
  
  it 'waits for the requisition status to be Closed' do
    status_is_closed              = page_assert(@info.requisition[:url])   { requisition.wait_for_page_to_load
                                                                             requisition.document_type_status.text.include?('Closed') }
    expect(status_is_closed).to be_true
  end

  it 'should have a valid PO number' do
    po_number_found               = page_assert(@info.requisition[:url])   { requisition.wait_for_page_to_load
                                      requisition.view_related_tab_toggle.click unless requisition.view_related_po_link.present?
                                      requisition.view_related_po_link.wait_until_present
                                      requisition.view_related_po_link.text =~ /[0-9]+/ }
    expect(po_number_found).to be_true
    @info.po                      = Hash.new
    @info.po[:id]                 = requisition.view_related_po_link.text.strip
    @info.po[:url]                = requisition.view_related_po_link.href
  end

  it 'opens the PO' do
    @ole.browser.goto(@info.po[:url])
    po_is_loaded                  = purchase_order.wait_for_page_to_load
    expect(po_is_loaded).to be_true
  end

  it 'retrieves a PO number' do
    @info.po[:po_id]              = purchase_order.document_type_id.text.strip
    po_number_given               = @info.po[:po_id]
    expect(po_number_given).to match(/[0-9]+/)
  end

  it 'has appropriate PO statuses' do
    po_status                     = purchase_order.document_status.text.strip
    document_status               = purchase_order.document_type_status.text.strip
    expect(po_status).to          match(/FINAL/)
    expect(document_status).to    match(/Open/)
  end

  it 'can receive the PO' do
    purchase_order.receiving_button.when_present.click
  end

  it 'opens a receiving document' do
    receiving_doc_is_loaded       = receiving.wait_for_page_to_load
    expect(receiving_doc_is_loaded).to be_true
  end

  it 'receives the line item' do
    receiving.receiving_line.receive_button.when_present.click
  end

  it 'submits the receiving document' do
    receiving.submit_button.click
    receiving.wait_for_page_to_load
    success_message_given         = receiving.submit_message.present?
    expect(success_message_given).to be_true
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
    po_id_on_invoice              = invoice.current_items_line.po_number.when_present.text.strip
    expect(po_id_on_invoice).to eq(@info.po[:id])
  end

  it 'saves the invoice' do
    @info.invoice[:id]  = invoice.document_id.when_present.text.strip
    @info.invoice[:url] = invoice.lookup_url(@info.invoice[:id])
    invoice.save_button.click
    invoice.wait_for_page_to_load
    document_status               = invoice.document_status.when_present.text.strip
    expect(document_status).to match('SAVED')
  end

  it 'approves the invoice' do
    invoice.approve_button.when_present.click
  end

  it 'waits for the invoice to be department-approved' do
    invoice_approved              = page_assert(@info.invoice[:url],120)    { invoice.document_type_status.when_present.text.strip.include?('Department-Approved') }
    expect(invoice_approved).to be_true
  end
end
