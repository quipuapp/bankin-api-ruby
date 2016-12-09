require 'spec_helper'

describe "quick test" do
  it "test me" do
    Bankin.configure do |config|
      config.client_id = '7031d0166fd44e268f6615db441f0978'
      config.client_secret = 'uxZFmARtpZXyOYldYqcGphmVcv3tWHDbcar5dG7DkuGal5IqlORpUHZ5mPuDAZmF'
    end


    user = Bankin::User.authenticate('uncoder@gmail.com', 'testpassword')
    p user.updated_transactions
    p user.transactions.load_all!.size
  end
end
