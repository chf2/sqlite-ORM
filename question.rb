require_relative 'questions_database.rb'
require_relative 'model.rb'

class Question < Model
  def self.find_by_author_id(author_id)
    raw_data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.user_id = ?
    SQL

    questions = []
    raw_data.each do |row|
      questions << Question.new(row)
    end

    questions
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.table_name
    'questions'
  end

  attr_accessor :title, :body
  def initialize(attrs = {})
    @id, @title, @body, @user_id =
      attrs['id'], attrs['title'], attrs['body'], attrs['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def params
    [@title, @body, @user_id, @id]
  end

end
