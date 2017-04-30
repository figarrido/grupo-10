class User < ApplicationRecord
	has_many :numbers
	has_many :raffle_participating, through: :numbers, source: :raffle
end
