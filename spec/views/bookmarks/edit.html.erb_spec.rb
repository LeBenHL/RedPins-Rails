require 'spec_helper'

describe "bookmarks/edit" do
  before(:each) do
    @bookmark = assign(:bookmark, stub_model(Bookmark,
      :user_id => 1,
      :event_id => "MyString",
      :integer => "MyString"
    ))
  end

  it "renders the edit bookmark form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bookmarks_path(@bookmark), :method => "post" do
      assert_select "input#bookmark_user_id", :name => "bookmark[user_id]"
      assert_select "input#bookmark_event_id", :name => "bookmark[event_id]"
      assert_select "input#bookmark_integer", :name => "bookmark[integer]"
    end
  end
end
