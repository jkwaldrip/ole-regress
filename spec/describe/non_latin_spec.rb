require 'rspec'
require 'spec_helper.rb'

describe 'Non-Latin characters' do

  include OLE_QA::RegressionTest::Assertions
  include_context 'Marc Editor'

  before :all do
    @alpha                         = YAML.load_file('data/alpha/non_latin.yml')
    @bib_record                   = OpenStruct.new
    @bib_record.line_245a         = "|a#{OLE_QA::Framework::String_Factory.alphanumeric(12)}"
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
end
