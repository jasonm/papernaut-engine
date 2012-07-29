class DiscussionHasContentPage < ActiveRecord::Migration
  def up
    remove_column :discussions, :content_url
    add_column :discussions, :content_page_id, :integer
  end

  def down
    remove_column :discussions, :content_page_id
    add_column :discussions, :content_url, :string
  end
end
