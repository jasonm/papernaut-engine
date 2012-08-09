class CreateLinksBetweenDiscussionAndPages < ActiveRecord::Migration
  def up
    create_table :links do |t|
      t.integer :discussion_id
      t.integer :page_id

      t.timestamps
    end

    add_index :links, [:page_id, :discussion_id], :unique => true
    add_index :links, :discussion_id
    add_index :links, :page_id

    remove_column :discussions, :content_page_id
  end

  def down
    add_column :discussions, :content_page_id, :integer

    remove_index :links, :column => :page_id
    remove_index :links, :column => :discussion_id
    remove_index :links, :column => [:page_id, :discussion_id]

    drop_table :links
  end
end
