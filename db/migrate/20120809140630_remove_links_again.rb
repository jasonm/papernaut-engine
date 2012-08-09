class RemoveLinksAgain < ActiveRecord::Migration
  def up
    drop_table :links
  end

  def down
    create_table :links do |t|
      t.integer :parent_page_id
      t.integer :child_page_id

      t.timestamps
    end
  end
end
