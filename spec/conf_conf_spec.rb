require 'conf_conf'

module Rails; end;

describe ConfConf do
  let(:configuration){ double() }
  before { allow(Rails).to receive(:configuration).and_return(configuration) }

  it "sets a value from the environment" do
    ENV["TEST_KEY"] = "hey"
    expect(configuration).to receive(:test_key=).with("hey")

    ConfConf.rails_configuration do
      config :test_key
    end
  end

  it "sets the default value when key not present" do
    expect(configuration).to receive(:key_not_present=).with("hey")

    ConfConf.rails_configuration do
      config :key_not_present, default: "hey"
    end
  end

  it "sets value from specified environment key" do
    ENV["TEST_KEY"] = "hey"
    expect(configuration).to receive(:other_key=).with("hey")

    ConfConf.rails_configuration do
      config :other_key, from: "TEST_KEY"
    end
  end

  it "throws an exception when required key not present" do
    expect {
      ConfConf.rails_configuration do
        config :key_not_present
      end
    }.to raise_error(ConfConf::MissingConfigurationValueError)
  end

  it "evaluates a block to establish the actual configuration value" do
    ENV["INTEGER_VALUE"] = "2"

    expect(configuration).to receive(:integer_value=).with(2)

    ConfConf.rails_configuration do
      config :integer_value do |value|
        value.to_i
      end
    end
  end
end
