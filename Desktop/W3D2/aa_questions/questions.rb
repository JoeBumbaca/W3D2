require 'sqlite3'
require'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

   def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class Users
  attr_accessor :id, :fname, :lname

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0

    Users.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND
        lname = ?
    SQL
    return nil unless user.length > 0

    Users.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    [Replies.find_by_user_id(@id)]
  end

end

class Questions
  attr_accessor :id, :title, :body, :author_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question.length > 0

    Questions.new(question.first)
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless question.length > 0

    Questions.new(question.first)
  end


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    Users.find_by_id(@author_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end
end

class Replies
   attr_accessor :id, :reply, :body, :question_id, :parent_reply, :user_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless reply.length > 0

    Replies.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless reply.length > 0

    Replies.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless reply.length > 0

    Replies.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @reply = options['reply']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
  end

  def author
    Users.find_by_id(@user_id)
  end

  def question
    Questions.find_by_id(@question_id)
  end

  def parent_reply
    Replies.find_by_id(@parent_reply)
  end

  def child_replies
    reply = QuestionsDBConnection.instance.execute(<<-SQL)
    SELECT
      id
    FROM
      replies
    WHERE
      parent_reply = id
    SQL

    reply
  end

end

class QuestionLikes
  attr_accessor :question_id, :user_id
  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end

  def self.find_user(question_id)
    question_likes = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN users
        ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL
    return nil unless question_likes.length > 0

    QuestionLikes.new(question_likes.first)
  end

  def self.find_question(user_id)
    question_likes = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN questions
        ON questions.id = question_likes.question_id
      WHERE
        user_id = ?
    SQL
    return nil unless question_likes.length > 0

    QuestionLikes.new(question_likes.first)
  end

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end

class QuestionFollows
   attr_accessor :question_id, :user_id
  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollows.new(datum) }
  end

  def self.find_user(question_id)
    question_follows = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN users
        ON users.id = question_follows.user_id
      WHERE
        question_id = ?
    SQL
    return nil unless question_follows.length > 0

    QuestionFollows.new(question_follows.first)
  end

  def self.find_question(user_id)
    question_follows = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN questions
        ON questions.id = question_follows.question_id
      WHERE
        user_id = ?
    SQL
    return nil unless question_follows.length > 0

    QuestionFollows.new(question_follows.first)
  end


  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end