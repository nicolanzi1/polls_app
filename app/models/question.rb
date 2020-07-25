# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  text       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  poll_id    :integer          not null
#
# Indexes
#
#  index_questions_on_poll_id  (poll_id)
#
class Question < ApplicationRecord
    validates :text, presence: true

    has_many :answer_choices,
        primary_key: :id,
        class_name: 'AnswerChoice',
        foreign_key: :question_id

    belongs_to :poll,
        primary_key: :id,
        class_name: 'Poll',
        foreign_key: :poll_id

    has_many :responses,
        through: :answer_choices,
        source: :responses
end
