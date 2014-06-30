require 'conf_conf'

module Rails; end;

describe ConfConf do
  context "#configuration" do
    it "sets a value from the environment" do
      ENV["TEST_KEY"] = "hey"

      configuration = ConfConf.configuration {
        config :test_key
      }

      expect(configuration.test_key).to eq("hey")
    end
  end

  context "#rails_configuration" do
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

    it "logs the configuration if told to" do
      logger = double()
      allow(logger).to receive(:info)
      allow(Rails).to receive(:logger).and_return logger
      expect(configuration).to receive(:integer_value=).with(2)

      ConfConf.log_config = true

      ConfConf.rails_configuration do
        config :integer_value do |value|
          value.to_i
        end
      end
    end
  end

  it "logs the configuration if told to" do
    logger = double()
    allow(logger).to receive(:info)
    allow(Rails).to receive(:logger).and_return logger
    expect(configuration).to receive(:integer_value=).with(2)


    ConfConf.log_config = true

    ConfConf.rails_configuration do
      config :integer_value do |value|
        value.to_i
      end
    end
  end
end
