class RemoveDiscussionIdentifier < ActiveRecord::Migration
  def up
    remove_column :discussions, :identifier
  end

  def down
    add_column :discussions, :identifier, :string
  end
end
