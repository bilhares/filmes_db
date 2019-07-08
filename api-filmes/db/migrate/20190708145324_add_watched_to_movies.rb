class AddWatchedToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :watched, :boolean
  end
end
