class AddIdentifiedAtToPages < ActiveRecord::Migration
  def up
    add_column :pages, :identified_at, :datetime

    execute 'UPDATE pages SET identified_at = created_at'
  end

  def down
    remove_column :pages, :identified_at
  end
end
