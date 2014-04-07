require 'rspec'
require 'spec_helper.rb'

describe 'Non-Latin characters' do

  include OLE_QA::RegressionTest::Assertions
  include_context 'Marc Editor'
  include_context 'Describe Workbench'

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
    expect(@alpha.keys).to eq([:arabic, :cyrillic, :greek,
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
      expect(message.when_present.text).to match(/success/)
    end
  end

   context 'persist on a Marc record' do
     it 'retrieved from a Workbench search' do
       verify(60) { title_search(@bib_record.title) }
       workbench.title_in_results(@bib_record.title).when_present.click
       Watir::Wait.until {@ole.windows.count > 1}
       @ole.windows[-1].use
     end

     it 'in Arabic' do
       bib_editor.data_line.line_number = 2
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:arabic])
     end

     it 'in Cyrillic' do
       bib_editor.data_line.line_number = 3
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:cyrillic])
     end

     it 'in Greek' do
       bib_editor.data_line.line_number = 4
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:greek])
     end

     it 'in Hangul' do
       bib_editor.data_line.line_number = 5
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:hangul])
     end

     it 'in Hebrew' do
       bib_editor.data_line.line_number = 6
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:hebrew])
     end
    
     it 'in Hiragana' do
       bib_editor.data_line.line_number = 7
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:hiragana])
     end

     it 'in Katakana' do
       bib_editor.data_line.line_number = 8
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:katakana])
     end

     it 'in Persian' do
       bib_editor.data_line.line_number = 9
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:persian])
     end

     it 'in Simplified Hanzi' do
       bib_editor.data_line.line_number = 10
       expect(bib_editor.data_line.data_field.when_present.value).to include(@alpha[:simplified_hanzi_short])
     end
   end
end
