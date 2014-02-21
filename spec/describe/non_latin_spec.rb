require 'rspec'
require 'spec_helper.rb'

describe 'Non-Latin characters' do

  include OLE_QA::RegressionTest::Assertions
  include_context 'Marc Editor'
  include_context 'Describe Workbench'

  let(:workbench)       { OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole) }

  before :all do
    @alpha                         = YAML.load_file('data/alpha/non_latin.yml')
    @bib_record                   = OpenStruct.new
    @bib_record.title             = OLE_QA::Framework::String_Factory.alphanumeric(12)
    @bib_record.line_245a         = "|a#{@bib_record.title}"
    @bib_record.line_500a1        = "|aArabic #{@alpha[:arabic]}"
    @bib_record.line_500a2        = "|aCyrillic #{@alpha[:cyrillic]}"
    @bib_record.line_500a3        = "|aGreek #{@alpha[:greek]}"
    @bib_record.line_500a4        = "|aHangul #{@alpha[:hangul]}"
    @bib_record.line_500a5        = "|aHebrew #{@alpha[:hebrew]}"
    @bib_record.line_500a6        = "|aHiragana #{@alpha[:hiragana]}"
    @bib_record.line_500a7        = "|aKatakana #{@alpha[:katakana]}"
    @bib_record.line_500a8        = "|aPersian #{@alpha[:persian]}"
    @bib_record.line_500a9        = "|aSimplified Hanzi (Short List) #{@alpha[:simplified_hanzi_short]}"
  end

  it 'should be loaded into a hash' do
    @alpha.keys.should eq([:arabic, :cyrillic, :greek,
                          :hangul, :hebrew, :hiragana,
                          :katakana, :persian,
                          :simplified_hanzi_short])
  end

  it 'can be written to a Marc record' do
    bib_editor.open
    bib_editor.data_line.tag_field.when_present.set('245')
    bib_editor.data_line.data_field.when_present.set(@bib_record.line_245a)
    add_data_line('500',@bib_record.line_500a1)
    add_data_line('500',@bib_record.line_500a2)
    add_data_line('500',@bib_record.line_500a3)
    add_data_line('500',@bib_record.line_500a4)
    add_data_line('500',@bib_record.line_500a5)
    add_data_line('500',@bib_record.line_500a6)
    add_data_line('500',@bib_record.line_500a7)
    add_data_line('500',@bib_record.line_500a8)
    add_data_line('500',@bib_record.line_500a9)
    bib_editor.save_record
    bib_editor.messages.each do |message|
      message.when_present.text.should =~ /success/
    end
  end

   context 'persist on a Marc record' do
     it 'retrieved from a Workbench search' do
       verify(60) {
         workbench.open
         workbench.search_field_1.when_present.set(@bib_record.title)
         workbench.search_button.click
         workbench.wait_for_page_to_load
         workbench.result_present?(@bib_record.title)
       }.should be_true
       workbench.view_by_text(@bib_record.title).when_present.click
       Watir::Wait.until {@ole.windows.count > 1}
       @ole.windows[-1].use
     end

     it 'in Arabic' do
       bib_editor.readonly_data_field(2).when_present.text.should include(@alpha[:arabic])
     end

     it 'in Cyrillic' do
       bib_editor.readonly_data_field(3).when_present.text.should include(@alpha[:cyrillic])
     end

     it 'in Greek' do
       bib_editor.readonly_data_field(4).when_present.text.should include(@alpha[:greek])
     end

     it 'in Hangul' do
       bib_editor.readonly_data_field(5).when_present.text.should include(@alpha[:hangul])
     end

     it 'in Hebrew' do
       bib_editor.readonly_data_field(6).when_present.text.should include(@alpha[:hebrew])
     end
    
     it 'in Hiragana' do
       bib_editor.readonly_data_field(7).when_present.text.should include(@alpha[:hiragana])
     end

     it 'in Katakana' do
       bib_editor.readonly_data_field(8).when_present.text.should include(@alpha[:katakana])
     end

     it 'in Persian' do
       bib_editor.readonly_data_field(9).when_present.text.should include(@alpha[:persian])
     end

     it 'in Simplified Hanzi' do
       bib_editor.readonly_data_field(10).when_present.text.should include(@alpha[:simplified_hanzi_short])
     end
   end
end
