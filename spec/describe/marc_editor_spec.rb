require 'rspec'
require 'spec_helper.rb'

describe 'The Marc Editor' do
  include_context 'Create a Marc Record'

  it 'opens the bib editor' do
    bib_editor.open
  end

  it 'creates a new bib record' do
    new_bib_record
  end

  it 'creates a new instance' do
    new_instance
  end
  
  it 'creates a new item' do
    new_item
  end

  it 'closes the editor screen' do
    bib_editor.close_button.click if bib_editor.close_button.present?
  end
end
