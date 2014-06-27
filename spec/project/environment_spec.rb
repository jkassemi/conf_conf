require 'spec_helper'

describe ConfConf::Project::Environment do
  subject                { described_class.new(project, environment_name) }
  let(:project)          { ConfConf::Project.new }
  let(:environment_name) { 'test' }

  it 'sets encrypted environment variable' do
    subject.set('VARIABLE_NAME', 'abcd')
  end

  it 'gets and decrypts environment variable' do
    subject.set('VARIABLE_NAME', 'abcd')
    subject.get('VARIABLE_NAME')
  end

  it 'removes environment variable' do
    subject.set('VARIABLE_NAME', 'abcd')
    subject.remove('VARIABLE_NAME')
  end
end
