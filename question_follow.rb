require_relative 'questions_database.rb'
require_relative 'model.rb'

class QuestionFollow < Model
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      INNER JOIN
        users ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    followers.map { |f_hash| User.new(f_hash) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      INNER JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL

    questions.map { |q_hash| Question.new(q_hash) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_follows
      INNER JOIN
        questions ON questions.id = question_follows.question_id
      GROUP BY question_id
      ORDER BY COUNT(*) desc
      LIMIT ?
    SQL

    questions.map { |q_hash| Question.new(q_hash) }
  end

  def self.table_name
    'question_follows'
  end

  def initialize(attrs = {})
    @id, @user_id, @question_id =
      attrs['id'], attrs['user_id'], attrs['question_id']
  end
end
