class CreateLinksBetweenPages < ActiveRecord::Migration
  def up
    create_table :links do |t|
      t.integer :parent_page_id
      t.integer :child_page_id

      t.timestamps
    end
  end

  def down
    drop_table :links
  end
end
