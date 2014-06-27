require 'spec_helper'

describe ConfConf::Project::Environment::Storage do
  before do
    stub_const('RbNaCl', MockRbNaCl)
    stub_const('File', MockFile)
  end

  let(:developer) {
    pretty_public_key  = Base64.strict_encode64(developer_private_key.public_key.to_s)
    ConfConf::Project::Developer.new(pretty_public_key)
  }

  let(:developer_private_key) {
    RbNaCl::PrivateKey.generate
  }

  let(:project) {
    project = ConfConf::Project.new
    project.developers.add(developer)
    project.developers.save
    project
  }

  let(:environment) {
    instance_double('ConfConf::Environment', {
      name: environment_name,
      schema: {},
      variables: { 'VAR1' => 'VAL1' }
    })
  }

  let(:environment_name) {
    "environment-#{rand(10e6)}"
  }

  it 'encrypts and saves an environment' do
    described_class.save_project_environment(project, environment)
    expect(File.fs).to include("config/conf_conf/environments/#{environment_name}.json")

    encrypted_environment_json   = File.read("config/conf_conf/environments/#{environment_name}.json")
    encrypted_environment_config = MultiJson.load(encrypted_environment_json)
    encrypted_environment        = RbNaCl::Info.new(encrypted_environment_config['encrypted_environment'])

    expect(encrypted_environment.secret_key_encrypted?).to be(true)
  end

  it 'adds an encrypted version of the secret key for the author' do
    described_class.save_project_environment(project, environment)

    encrypted_environment_json   = File.read("config/conf_conf/environments/#{environment_name}.json")
    encrypted_environment_config = MultiJson.load(encrypted_environment_json)

    author_public_key = encrypted_environment_config["author_public_key"]
    developer_public_keys = encrypted_environment_config["encrypted_environment_secret_key"].keys
    expect(developer_public_keys).to include(author_public_key)
  end

  it 'loads an encrypted environment as an author' do
    described_class.save_project_environment(project, environment)
    environment = described_class.load_project_environment(project, environment_name)

    expect(environment).to be_a(ConfConf::Project::Environment)
    expect(environment.variables['VAR1']).to eq('VAL1')
  end

  it 'loads an encrypted environment as an authorized developer' do
    described_class.save_project_environment(project, environment)

    pretty_developer_private_key = Base64.strict_encode64(developer_private_key.to_s)
    current_developer = ConfConf::Project::Developer.new(developer.pretty_public_key, pretty_developer_private_key)
    expect(ConfConf::Project::Developer).to receive(:current).and_return(current_developer)

    environment = described_class.load_project_environment(project, environment_name)
    expect(environment).to be_a(ConfConf::Project::Environment)
  end

  it 'fails to load an encrypted environment when not authenticated' do
    described_class.save_project_environment(project, environment)

    private_key        = RbNaCl::PrivateKey.generate
    pretty_private_key = Base64.strict_encode64(private_key.to_s)
    pretty_public_key  = Base64.strict_encode64(private_key.public_key.to_s)
    unauthorized_developer  = ConfConf::Project::Developer.new(pretty_public_key, pretty_private_key)
    expect(ConfConf::Project::Developer).to receive(:current).and_return(unauthorized_developer)

    expect {
      described_class.load_project_environment(project, environment_name)
    }.to raise_error(ConfConf::Project::Environment::NotAuthorizedError)
  end
end
