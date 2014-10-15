require 'spec_helper'

describe SSH::Manager do 

  subject { SSH::Manager }

  describe '.list' do
    it 'prints list' do
      expect(STDOUT).to receive(:puts).with("list")
      subject::Client.list
    end
  end
end

