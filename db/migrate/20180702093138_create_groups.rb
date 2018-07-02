class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.integer :gid

      t.timestamps
    end

    add_index :groups, :name
  end
end
