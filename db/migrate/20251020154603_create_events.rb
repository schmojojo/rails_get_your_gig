class CreateEvents < ActiveRecord::Migration[7.1]

  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.string :contact
      t.date :date
      t.string :category
      t.string :location
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
