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

    def completed_polls_sql
        # SQL queries method
        Poll.find_by_sql(<<-SQL)
            SELECT
                polls.*
            FROM
                polls
            JOIN
                questions ON polls.id = qiestions.poll_id
            JOIN
                answer_choices ON questions.id = answer_choices
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    responses
                WHERE
                    respondent_id = #{self.id}
            ) AS responses ON answer_choices.id = responses.answer_choices_id
            GROUP BY
                polls.id
            HAVING
                COUNT(DISTINCT questions.id) = COUNT(responses.*)
        SQL
    end

    def completed_polls
        # ActiveRecord method
        polls_with_completion_counts
            .having('COUNT(DISTING questions.id) = COUNT(responses.id')
    end

    def incomplete_polls
        polls_with_completion_counts
            .having('COUNT(DISTINCT questions.id) > COUNT(responses.id')
            .having('COUNT(responses.id) > 0')
    end

    private

    def polls_with_completion_counts
        joins_sql = <<-SQL
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    responses
                WHERE
                    respondent_id = #{self.id}
            ) AS responses ON answer_choices.id = responses.answer_choice_id
        SQL

        Poll.joins(questions: :answer_choices)
            .joins(joins_sql)
            .group('polls.id')
    end
end
