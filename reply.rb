require_relative 'questions_database.rb'
require_relative 'model.rb'

class Reply < Model
  def self.find_by_user_id(user_id)
    raw_data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    replies = []
    raw_data.each do |row|
      replies << Reply.new(row)
    end

    replies
  end

  def self.find_by_question_id(question_id)
    raw_data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    replies = []
    raw_data.each do |row|
      replies << Reply.new(row)
    end

    replies
  end

  def self.table_name
    'replies'
  end

  attr_accessor :body

  def initialize(attrs = {})
    @id, @question_id, @parent_id, @user_id, @body =
      attrs['id'], attrs['question_id'], attrs['parent_id'],
      attrs['user_id'], attrs['body'];
  end

  def author
    User.find_by_id(@user_id)
  end

  def parent_reply
    @parent_id.nil? ? nil : Reply.find_by_id(@parent_id)
  end

  def child_replies
    raw_data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_id = @id
    SQL

    children = []
    raw_data.each do |row|
      children << Reply.new(row)
    end

    children
  end

  def question
    Question.find_by_id(@question_id)
  end

  def params
    [@question_id, @parent_id, @user_id, @body, @id]
  end

end
