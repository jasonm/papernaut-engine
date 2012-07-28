class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :discussion_id
      t.integer :page_id
      t.integer :depth

      t.timestamps
    end
  end
end
