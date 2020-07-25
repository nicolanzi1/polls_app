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

    def results_n_plus_1
        # Writing the N+1 method
        results = {}
        self.answer_choices.each do |ac|
            results[ac.text] = ac.responses.count
        end
        results
    end

    def resulst_2_queries
        # Through includes queries where all responses are transferred
        results = {}
        self.answer_choices.includes(:responses).each do |ac|
            results[ac.text] = ac/responses.length
        end
        results
    end

    def results_1_query_SQL
        # Through SQL queries
        acs = AnswerChoice.find_by_sql([<<-SQL, id])
            SELECT
                answer_choices.*, COUNT(responses.id) AS num_responses
            FROM
                answer_choices
            LEFT OUTER JOIN responses
                ON answer_choices.id = responses.answer_choices_id
            WHERE
                answer_choices.questions_id = ?
            GROUP BY
                answer_choices.id
        SQL

        acs.inject({}) do |results, ac|
            results[ac.text] = ac.num_responses; results
        end
    end

    def results
        # And with ActiveRecord(best approach, more efficient)
        acs = self.answer_choices
            .select("answer_choices.text, COUNT(responses.id) as num_responses")
            .left_outer_joins(:responses).group("answer_choices.id")

# # If using Rails 4, the method should be written as below, because the is no left_outer_joins method
#     acs = self.answer_choices
#         .select("answer_choices.text, COUNT(responses.id), as num_responses")
#         .joins(<<-SQL).group("answer_choices.id")
#             LEFT OUTER JOIN responses
#                 ON answer_choices.id = responses.answer_choices_id
#         SQL

        acs.inject({}) do |results, ac|
            results[ac.text] = ac.num_responses; results
        end
    end
end
