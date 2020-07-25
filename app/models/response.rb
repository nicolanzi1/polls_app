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

    def sibling_responses
        binds = { answer_choice_id: self.answer_choice_id, id: self.id }
        Response.find_by_sql([<<-SQL, binds])
            SELECT
                responses.*
            FROM (
                SELECT
                    questions.*
                FROM
                    questions
                JOIN
                    answer_choices ON questions.id = answer_choices.question_id
                WHERE
                    answer_choices.id = :answer_choice_id
            ) AS questions
            JOIN
                answer_choices ON questions.id = answer_choices.question_id
            JOIN
                responses ON answer_choices.id = responses.answer_choice_id
            WHERE
                (:id IS NULL) OR (responses.id != :id)
        SQL
    end

    def respondent_already_answered?
        sibling_responses.exists?(respondent_id: self.respondent_id)
    end

    private

    def respondent_is_not_poll_author
        poll_author_id = Poll
            .joins(questions: :answer_choices)
            .where('answer_choices.id = ?', self.answer_choice_id)
            .pluck('polls.author_id')
            .first

        if poll_author_id == self.respondent_id
            error[:respondent_id] << 'cannot be poll author'
        end
    end

    def not_duplicate_response
        if respondent_already_answered?
            error[:respondent_id] << 'cannot vote twice for question'
        end
    end
end
