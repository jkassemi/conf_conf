require 'spec_helper'

describe ConfConf::Project::Developers do
  let(:developer) { ConfConf::Project::Developer.new(pretty_public_key) }
  let(:pretty_public_key) { Base64.strict_encode64('hello') }

  before do
    stub_const('File', MockFile)
  end

  it 'adds a new developer to config/conf_conf/developers.json' do
    subject.add(developer)
    subject.save

    expect(subject.keys.length).to eq(1)
    expect(subject.keys.first).to eq(pretty_public_key)
    expect(File.exists?('config/conf_conf/developers.json')).to be(true)
  end

  it 'removes a developer from config/conf_conf/developers.json' do
    subject.add(developer)
    subject.remove(developer)
    expect(subject.keys.length).to eq(0)
  end
end
