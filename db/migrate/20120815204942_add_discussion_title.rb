class AddDiscussionTitle < ActiveRecord::Migration
  def change
    add_column :discussions, :title, :string, limit: 1024
  end
end
