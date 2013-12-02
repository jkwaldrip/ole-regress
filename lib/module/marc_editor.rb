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

module OLE_QA::RegressionTest
  # This module includes methods to automatically fill in a Marc Editor record.
  module MarcEditor
    # Create a Marc bibliographic record and return the results of the operation in a Hash.
    # @param [Object] bib_editor The actual bib editor page object instantiated from the OLE_QA::Framework.
    # @param [Array] bib_ary  The array containing keyed hashes for Marc bib record lines.
    #
    # - Example Array:
    #   [ {:tag => '008',
    #      :value => 'ControlFieldRandomText'},
    #     {:tag => '245',
    #     :ind1 => '0',
    #     :ind2 => '0',
    #     :value => '|aTesting Bib Editor'},
    #     {:tag => '100',
    #     :ind1 => '',
    #     :ind2 => '',
    #     :value => '|aOLE QA Smoketest'}
    #   ]
    #
    # @note The output hash will have a key for each item in the input hash that was entered successfully.
    #   In the case of numbered Marc fields, the key will be the field number.
    def create_bib(bib_editor, bib_ary)
      hsh_out = Hash.new

      # Gather control field lines from array.
      control_lines = bib_ary.select { |marc_line| ('001'..'008').include?(marc_line[:tag]) }
      bib_ary.delete_if { |marc_line| ('001'..'008').include?(marc_line[:tag]) }

      # Wait for the actual bib editor to load.
      # - This may be superfluous, but better to lose at races than lose at Selenium.
      bib_editor.wait_for_page_to_load

      # Click the 'Set Leader Field' button.
      bib_editor.set_button.when_present.click

      # Set control fields individually.
      # - This could be made iterative, but the challenge introduced by 006 and 007 being repeatable
      #   and the lack of necessity for using repeatable 006 & 007 fields in basic smoketesting
      #   so far makes this an unnecessary level of complexity.
      # - Only fields 001, 003, 005, 006, 007, and 008 are used at present.  (2013/09/17)
      control_lines.each do |line|
        case line[:tag]
        when '001'
          bib_editor.control_001_field.when_present.set(line[:value])
        when '003'
          bib_editor.control_003_field.when_present.set(line[:value])
        when '005'
          bib_editor.control_005_field.when_present.set(line[:value])
        when '006'
          bib_editor.control_006_line_1.field.when_present.set(line[:value])
        when '007'
          bib_editor.control_007_line_1.field.when_present.set(line[:value])
        when '008'
          bib_editor.control_008_field.when_present.set(line[:value])
        end
        hsh_out[line[:tag].to_sym] = true
      end

      # Enter regular Marc data lines.
      bib_ary.each do |line|
        i = bib_ary.index(line) + 1
        current_line = bib_editor.data_line
        current_line.line_number = i
        current_line.tag_field.when_present.set(line[:tag])
        current_line.ind1_field.when_present.set(line[:ind1]) unless line[:ind1].nil?
        current_line.ind2_field.when_present.set(line[:ind2]) unless line[:ind2].nil?
        current_line.data_field.when_present.set(line[:value])
        unless i == bib_ary.count
          current_line.add_button.when_present.click
        end
        hsh_out[line[:tag].to_sym] = true
      end
        
      hsh_out[:message] = bib_editor.save_record
      hsh_out[:pass?]   = true

    rescue => e
      hsh_out[:error]     = e.message
      hsh_out[:backtrace] = e.backtrace
    ensure
      hsh_out
    end

    # Create a Marc instance/holdings record and return the results of the operation in a Hash.
    # @param [Object] instance_editor The actual instance editor page object instantiated from the OLE_QA::Framework.
    # @param [Hash] instance_info  A keyed hash containing the information to enter into the instance record.
    #
    # - Example Hash:
    #   {:location => 'B-EDUC/BED-STACKS',
    #     :call_number => 'PJ1135 .A45 2010',
    #     :call_number_type => 'LCC'
    #     :instance_number => 1}
    #
    #   - :instance_number is the sequential number of the instance record attached to the bib record, starting on 1.
    # 
    # @note The output hash will have a key for each item in the input hash that was entered successfully.
    #
    def create_instance(instance_editor, instance_info)
      hsh_out = Hash.new

      # Set instance number to 1 if not found.
      instance_info[:instance_number] = 1 if instance_info[:instance_number].nil?

      # Open instance record.
      instance_editor.holdings_link(instance_info[:instance_number]).when_present.click
      instance_editor.wait_for_page_to_load

      instance_editor.location_field.when_present.set(instance_info[:location])
      hsh_out[:location] = true

      instance_editor.call_number_field.when_present.set(instance_info[:call_number])
      instance_editor.call_number_type_selector.when_present.select_value(instance_info[:call_number_type])
      hsh_out[:call_number],hsh_out[:call_number_type] = true
      hsh_out[:message] = instance_editor.save_record
      hsh_out[:pass?]   = true
    rescue => e
      hsh_out[:error]     = e.message
      hsh_out[:backtrace] = e.backtrace
      hsh_out[:pass?]     = false
    ensure
      hsh_out
    end

    # Create a Marc item record and return the results of the operation in a Hash.
    # @param [Object] item_editor  The Actual item editor page object instantiated from the OLE_QA::Framework.
    # @param [Hash] instance_info  A keyed hash containing the information to enter into the item record.
    #
    # - Example Hash:
    #   {:item_type => 'book',
    #     :item_status => 'Available',
    #     :barcode => '6569660552130812946'}
    #
    #   - :instance_number is the sequential number of the instance record attached to the bib record, starting on 1.
    #   - :item_number is the sequential number of the item record attached to the instance record, starting on 1.
    #
    # @note The output hash will have a key for each item in the input hash that was entered successfully.
    #
    def create_item(item_editor, item_info)
      hsh_out = Hash.new

      # Set instance & item numbers to 1 if not found.
      item_info[:instance_number] = 1 if item_info[:instance_number].nil?
      item_info[:item_number]     = 1 if item_info[:item_number].nil?

      # Open item record.
      unless item_editor.item_link(item_info[:item_number]).present?
        item_editor.holdings_icon(item_info[:instance_number]).when_present.click
        item_editor.item_link(item_info[:item_number]).wait_until_present
      end
      item_editor.item_link(item_info[:item_number]).click
      item_editor.wait_for_page_to_load

      item_editor.item_type_selector.when_present.select(item_info[:item_type])
      hsh_out[:item_type] = true

      item_editor.item_status_selector.when_present.select(item_info[:item_status])
      hsh_out[:item_status] = true

      item_editor.barcode_field.when_present.set(item_info[:barcode])
      hsh_out[:barcode] = true

      hsh_out[:message] = item_editor.save_record

    rescue => e
      hsh_out[:error]     = e.message
      hsh_out[:backtrace] = e.backtrace
    ensure
      hsh_out
    end
  end
end
