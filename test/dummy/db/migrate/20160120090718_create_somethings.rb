class CreateSomethings < ActiveRecord::Migration
  def change
    create_table :somethings do |t|
      t.string :paper
      t.string :stone

      t.timestamps null: false
    end
  end
end
