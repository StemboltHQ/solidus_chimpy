require 'spec_helper'

describe Spree::Chimpy do

  context "enabled" do
    before do
      allow(Spree::Chimpy::Interface::List).to receive_messages(new: :list)
      allow(Spree::Chimpy::Interface::Orders).to receive_messages(new: :orders)
      config(key: '1234', list_name: 'Members')
    end

    subject { described_class }

    specify      { is_expected.to be_configured }
    specify "attributes of Spree::Chimpy when configured" do
      expect(subject.list).to eq :list
      expect(subject.orders).to eq :orders
    end
  end

  context "disabled" do
    before { config(key: nil) }

    subject { described_class }

    specify      { is_expected.not_to be_configured }
    specify "attributes of Spree::Chimpy when not configured" do
      expect(subject.list).to be_nil
      expect(subject.orders).to be_nil
    end
  end

  context "sync merge vars" do
    let(:interface)     { double(:interface) }

    before do
      allow(Spree::Chimpy::Interface::List).to receive_messages(new: interface)
      config(key: '1234',
             list_name: 'Members',
             merge_vars: {'EMAIL' => :email, 'FNAME' => :first_name, 'LNAME' => :last_name})
    end

    it "adds var for each" do
      expect(interface).to receive(:merge_vars).and_return([])
      expect(interface).to receive(:add_merge_var).with('FNAME', 'First Name')
      expect(interface).to receive(:add_merge_var).with('LNAME', 'Last Name')

      subject.sync_merge_vars
    end

    it "skips vars that exist" do
      expect(interface).to receive(:merge_vars).and_return(%w(EMAIL FNAME))
      expect(interface).to receive(:add_merge_var).with('LNAME', 'Last Name')

      subject.sync_merge_vars
    end

    it "doesnt sync if all exist" do
      expect(interface).to receive(:merge_vars).and_return(%w(EMAIL FNAME LNAME))
      expect(interface).not_to receive(:add_merge_var)

      subject.sync_merge_vars
    end
  end

  def config(options = {})
    config = Spree::Chimpy::Configuration.new
    config.key        = options[:key]
    config.list_name  = options[:list_name]
    config.merge_vars = options[:merge_vars] || {}
    config
  end
end
