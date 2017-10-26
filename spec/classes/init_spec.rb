require 'spec_helper'
describe 'cloud_formation' do

  context 'with defaults for all parameters' do
    it { should contain_class('cloud_formation') }
  end
end
