require 'spec_helper'

describe "likes/show" do
  before(:each) do
    @like = assign(:like, stub_model(Like,
      :user_id => 1,
      :event_id => 2,
      :like => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/false/)
  end
end
