class Movie < ApplicationRecord
    before_create -> {self.watched = false}
    belongs_to :profile
end
