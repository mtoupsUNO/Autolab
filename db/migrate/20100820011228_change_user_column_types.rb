class ChangeUserColumnTypes < ActiveRecord::Migration
  def self.up
    change_column :users, :lecture, :string
    change_column :users, :year, :string
  end

  def self.down
    change_column :users, :lecture, :integer
    change_column :users, :year, :integer
  end
end
