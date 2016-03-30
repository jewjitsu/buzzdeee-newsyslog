require "spec_helper"

describe Puppet::Type.type(:newsyslog) do
  describe "when validating attributes" do
    it "should have :name be its namevar" do
      expect(described_class.key_attributes).to eq([:name])
    end

    [:owner, :group, :mode, :keep, :size, :when, :flags, \
     :monitor, :pidfile, :sigtype, :command].each do |property|
      it "should allow property (#{property})" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating values" do
    describe "ensure" do
      it "should support present as a value for ensure" do
        expect do
          described_class.new(:name => 'rotateme', :ensure => present).to_not \
            raise_error
        end
      end

      it "should support absent as a value for ensure" do
        expect do
          described_class.new(:name => 'rotateme', :ensure => absent).to_not \
            raise_error
        end
      end
      it "should not support other values" do
        expect { described_class.new(:name => 'foo', :ensure => :foo) }.to \
          raise_error(Puppet::Error, /Invalid value/)
      end
    end
  end
end
