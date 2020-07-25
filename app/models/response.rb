# == Schema Information
#
# Table name: responses
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  answer_choice_id :integer          not null
#  respondent_id    :integer          not null
#
# Indexes
#
#  index_responses_on_answer_choice_id  (answer_choice_id)
#  index_responses_on_respondent_id     (respondent_id)
#
class Response < ApplicationRecord
    belongs_to :answer_choice,
        primary_key: :id,
        class_name: 'AnswerChoice',
        foreign_key: :answer_choice_id

    belongs_to :respondent,
        primary_key: :id,
        class_name: 'User',
        foreign_key: :respondent_id

    has_one :question,
        through: :answer_choice,
        source: :question
end
