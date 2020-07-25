# == Schema Information
#
# Table name: answer_choices
#
#  id          :bigint           not null, primary key
#  text        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :integer          not null
#
# Indexes
#
#  index_answer_choices_on_question_id  (question_id)
#
class AnswerChoice < ApplicationRecord
    validates :text, presence: true

    belongs_to :question,
        primary_key: :id,
        class_name: 'Question',
        foreign_key: :question_id

    has_many :responses,
        primary_key: :id,
        class_name: 'Response',
        foreign_key: :answer_choice_id
end
