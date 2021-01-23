class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.string :name,        null: false
      t.string :url,         null: false, unique: true
      t.boolean :is_checked, default: false
      t.timestamps
    end
  end
end
