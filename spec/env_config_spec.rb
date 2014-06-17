require 'env_config'

module Rails; end;

describe EnvConfig do
  let(:configuration){ double() }
  before { allow(Rails).to receive(:configuration).and_return(configuration) }

  it "sets a value from the environment" do
    ENV["TEST_KEY"] = "hey"
    expect(configuration).to receive(:test_key=).with("hey")

    EnvConfig.rails_configuration do
      config :test_key
    end
  end

  it "sets the default value when key not present" do
    expect(configuration).to receive(:key_not_present=).with("hey")

    EnvConfig.rails_configuration do
      config :key_not_present, default: "hey"
    end
  end

  it "throws an exception when required key not present" do
    expect {
      EnvConfig.rails_configuration do
        config :key_not_present
      end
    }.to raise_error(EnvConfig::MissingConfigurationValueError)
  end

  it "evaluates a block to establish the actual configuration value" do
    ENV["INTEGER_VALUE"] = "2"

    expect(configuration).to receive(:integer_value=).with(2)

    EnvConfig.rails_configuration do
      config :integer_value do |value|
        value.to_i
      end
    end
  end
end
