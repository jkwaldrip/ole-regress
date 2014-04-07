require 'rspec'
require 'spec_helper'

describe 'OLE QA Framework' do
  it 'should start a new session' do
    expect(@ole).to be_an(OLE_QA::Framework::Session)
  end
end
