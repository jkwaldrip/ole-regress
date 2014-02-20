require 'rspec'
require 'spec_helper.rb'

describe 'Non-Latin characters' do

  include OLE_QA::RegressionTest::Assertions
  
  let(:alpha)               {YAML.load_file('data/alpha/non_latin.yml')}

  before :all do

  end

  it 'should be loaded into a hash' do
    alpha.keys.should eq([:arabic, :cyrillic, :greek,
                          :hangul, :hebrew, :hiragana,
                          :katakana, :persian,
                          :simplified_hanzi_short])
  end
end
