class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :url
      t.string :identifier

      t.timestamps
    end
  end
end
