# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  username   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
class User < ApplicationRecord
    validates :username, presence: true, uniqueness: true

    has_many :authored_polls,
        primary_key: :id,
        class_name: 'Poll',
        foreign_key: :author_id

    has_many :responses,
        primary_key: :id,
        class_name: 'Response',
        foreign_key: :respondent_id
end
