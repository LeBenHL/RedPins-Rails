class AddCanceledToEvents < ActiveRecord::Migration
  def change
    add_column :events, :canceled, :boolean, :null => false, :default => false
  end
end
