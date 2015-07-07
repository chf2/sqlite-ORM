require_relative 'questions_database.rb'
require_relative 'model.rb'

class QuestionLike < Model
  def self.liked_questions_for_user_id(user_id)
    liked_qs = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      INNER JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    liked_qs.map { |q_hash| Question.new(q_hash) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS num_likes
      FROM
        question_likes
      WHERE
        question_likes.question_id = ?
    SQL

    num_likes[0]['num_likes']
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      INNER JOIN
        users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    likers.map { |u_hash| User.new(u_hash) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      INNER JOIN
        questions ON question_likes.question_id = questions.id
      GROUP BY 
        question_likes.question_id
      ORDER BY 
        COUNT(*) desc
      LIMIT 
        ?
    SQL

    questions.map { |q_hash| Question.new(q_hash) }
  end

  def self.table_name
    'question_likes'
  end

  def initialize(attrs = {})
    @id = attrs['id']
    @user_id = attrs['user_id']
    @question_id = attrs['question_id']
  end
end
