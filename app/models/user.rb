class User < ApplicationRecord
	enum role: [:user, :admin]

	has_many :numbers
	has_many :raffle_participating, through: :numbers, source: :raffle
	has_many :raffles
	has_many :reactions
	has_one :wallet, dependent: :destroy
end