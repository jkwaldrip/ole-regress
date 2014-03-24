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

shared_context 'Marc Editor' do
  let(:bib_editor)                {OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)}

  def add_data_line(tag,value)
    bib_editor.data_line.add_button.click
    bib_editor.data_line.line_number += 1
    bib_editor.data_line.tag_field.when_present.set(tag)
    bib_editor.data_line.data_field.when_present.set(value)
  end
end

shared_context 'Create a Marc Record' do
  
  include OLE_QA::RegressionTest::MarcEditor
  
  before :all do
    @marc_record                = OpenStruct.new
    @marc_record.bib_info       = [
                                      {:tag             => '100',
                                      :value            => '|a' + OLE_QA::Framework::String_Factory.alphanumeric},
                                      {:tag             => '245',
                                      :value            => '|a' + OLE_QA::Framework::String_Factory.alphanumeric}
    ]
    @marc_record.instance_info  = {
                                      :location         => 'B-EDUC/BED-STACKS',
                                      :call_number      => OLE_QA::Framework::Bib_Factory.call_number,
                                      :call_number_type => 'LCC'
    }
    @marc_record.item_info      = {
                                      :item_type        => 'Book',
                                      :item_status      => 'Available',
                                      :barcode          => OLE_QA::Framework::Bib_Factory.barcode
    }
  end

  let(:bib_editor)        { OLE_QA::Framework::OLELS::Bib_Editor.new(@ole) }
  let(:instance_editor)   { OLE_QA::Framework::OLELS::Instance_Editor.new(@ole) }
  let(:item_editor)       { OLE_QA::Framework::OLELS::Item_Editor.new(@ole) }
  
  def new_bib_record
    bib_editor.wait_for_page_to_load
    results = create_bib(bib_editor, @marc_record.bib_info)
    results[:error].should be_nil
    results[:message].should =~ /success/
    results[:pass?].should be_true
  end

  def new_instance
    results = create_instance(instance_editor, @marc_record.instance_info)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  def new_item
    results = create_item(item_editor, @marc_record.item_info)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  def close_editor
    bib_editor.close_button.click if bib_editor.close_button.present?
  end
end

shared_context 'Describe Workbench' do
  let(:workbench)       {OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)}

  # Seach for a bibliographic record by title and verify that it comes up in the search results.
  def title_search(title)
    workbench.open
    set_field(workbench.document_type_selector,'Bibliographic')
    workbench.wait_for_page_to_load
    set_field(workbench.search_type_selector,'Search')
    workbench.wait_for_page_to_load
    set_field(workbench.search_line.search_field,title)

    # @note Need to use .select_value as .select('phrase') and .select('As a Phrase') both return errors.
    #   Neither of these values can be used in a Watir::Wait.until { selector.include?(value) } statement,
    #   as neither of these will evaluate to true.  Note also that the option with selected="selected" may
    #   not update on the page to match the current selection value (e.g., even if 'As a Phrase' is
    #   selected, you may still see
    #     <option selected="selected" value="AND"></option>
    #   in the page source).
    workbench.search_line.search_scope_selector.when_present.select_value('phrase')
    workbench.search_line.search_scope_selector.value.should eq('phrase')

    set_field(workbench.search_line.field_selector,'Title')
    workbench.search_line.add_button.when_present.click
    workbench.wait_for_page_to_load
    workbench.search_button.click
    workbench.wait_for_page_to_load
    workbench.title_in_results?(title)
  end

  # Seach for a bibliographic record by author and verify that it comes up in the search results.
  def author_search(author)
    workbench.open
    set_field(workbench.document_type_selector,'Bibliographic')
    workbench.wait_for_page_to_load
    set_field(workbench.search_type_selector,'Search')
    workbench.wait_for_page_to_load
    set_field(workbench.search_line.search_field,author)

    # @note Need to use .select_value as .select('phrase') and .select('As a Phrase') both return errors.
    #   Neither of these values can be used in a Watir::Wait.until { selector.include?(value) } statement,
    #   as neither of these will evaluate to true.  Note also that the option with selected="selected" may
    #   not update on the page to match the current selection value (e.g., even if 'As a Phrase' is
    #   selected, you may still see
    #     <option selected="selected" value="AND"></option>
    #   in the page source).
    workbench.search_line.search_scope_selector.when_present.select_value('phrase')
    workbench.search_line.search_scope_selector.value.should eq('phrase')

    set_field(workbench.search_line.field_selector,'Author')
    workbench.search_line.add_button.when_present.click
    workbench.wait_for_page_to_load
    workbench.search_button.click
    workbench.wait_for_page_to_load
    workbench.text_in_results?(author)
  end
end