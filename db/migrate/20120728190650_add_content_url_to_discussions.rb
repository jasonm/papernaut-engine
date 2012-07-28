class AddContentUrlToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :content_url, :string
  end
end
