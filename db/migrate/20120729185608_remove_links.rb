class RemoveLinks < ActiveRecord::Migration
  def up
    drop_table :links
  end

  def down
    create_table :links do |t|
      t.integer :discussion_id
      t.integer :page_id
      t.integer :depth

      t.timestamps
    end
  end
end
