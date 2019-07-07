class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.integer :movie_id
      t.string :title
      t.text :overview
      t.string :poster
      t.float :vote_average
      t.integer :profile_id

      t.timestamps
    end
  end
end
