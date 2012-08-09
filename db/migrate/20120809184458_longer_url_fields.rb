class LongerUrlFields < ActiveRecord::Migration
  def up
    change_column :discussions, :url, :string, limit: 2048
    change_column :pages, :url, :string, limit: 2048
  end

  def down
    change_column :pages, :url, :string, limit: 255
    change_column :discussions, :url, :string, limit: 255
  end
end
