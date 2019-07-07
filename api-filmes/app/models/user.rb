class User < ApplicationRecord
    before_create -> {self.token = generate_token}

    has_many :profiles
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    private 
        def generate_token
            loop do
                token = SecureRandom.hex
                return token unless User.exists?({token: token})
            end
        end
end
