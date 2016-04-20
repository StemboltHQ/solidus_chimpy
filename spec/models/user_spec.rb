require 'spec_helper'

describe Spree::User do
  context "after create" do
    let(:subscription_double) { double Spree::Chimpy::Subscription }
    subject { FactoryGirl.create(:user_with_subscribe_option) }

    it "subscribes the user when the user is created" do
      expect_any_instance_of(Spree::User).
        to receive(:subscription).
        once.
        and_return(subscription_double)
      expect(subscription_double).to receive(:subscribe).once

      subject
    end
  end

  context "after destroy" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      expect(subscription).to receive(:subscribe)
      expect(Spree::Chimpy::Subscription).to receive(:new).at_least(1).and_return(subscription)
      @user = create(:user_with_subscribe_option)
    end

    it "submits after destroy" do
      expect(subscription).to receive(:unsubscribe)
      @user.destroy
    end
  end

  context "defaults" do
    it "subscribed by default" do
      Spree::Chimpy::Config.subscribed_by_default = true
      expect(described_class.new.subscribed).to be_truthy
    end

    it "doesnt subscribe by default" do
      Spree::Chimpy::Config.subscribed_by_default = false
      expect(described_class.new.subscribed).to be_falsey
    end
  end
end
