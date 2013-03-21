class ChangeTitleFromStringToTextInEvents < ActiveRecord::Migration
  def change
    change_column :events, :title, :text
  end
end
