class PagesHaveMultipleIdentifiers < ActiveRecord::Migration
  def up
    create_table :identifiers do |t|
      t.string :body
      t.integer :page_id
      t.timestamps
    end

    remove_column :pages, :identifier
  end

  def down
    add_column :pages, :identifier, :string
    drop_table :identifiers
  end
end
