require 'singleton'
require 'sqlite3'

class QuestionDatabase < SQLite3::Database 
  include Singleton
  
  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true 
  end   
end 

##############  Question  #########################

class Question 
    
  def self.find_all
    data = QuestionDatabase.instance.execute("SELECT * FROM questions")
    data.map {|info| Question.new(info)}
  end
  
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    data.map {|info| Question.new(info)}
  end
  
  def self.find_by_author_id(author_id)
    data = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions 
      WHERE
        author_id = ?
    SQL
    data.map {|info| Question.new(info)}
  end 
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  attr_accessor :title, :body
  attr_reader :id, :author_id
  
  def initialize(options)
    @id = options['id']
    @title = options['title'] 
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def author
    User.find_by_id(@author_id)
  end 
  
  def replies 
    Reply.find_by_question_id(@id)
  end 
  
  def followers 
    QuestionFollow.followers_for_question_id(@id)
  end
  
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(@id)[0]["likes"]
  end
  
end

##############  USER  #########################

class User
  
  def self.find_all
    data = QuestionDatabase.instance.execute("SELECT * FROM users")
    data.map {|info| User.new(info)}
  end
  
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    data.map {|info| User.new(info)}
  end
  
  def self.find_by_name(fname, lname)
    data = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
      AND
        lname = ?
    SQL
    data.map {|info| User.new(info)}
  end
  
  attr_accessor :fname, :lname
  attr_reader :id
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname'] 
    @lname = options['lname']
  end
  
  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
  end
  
  def followed_questions 
    QuestionFollow.followed_questions_for_user_id(@id)
  end 
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)[0]["questions_liked"]
  end
  
  def average_karma
    data = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        questions.id
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.questions_id
      WHERE
        questions_id IN (SELECT id FROM questions WHERE author_id = 2)
      GROUP BY
        questions.id

    SQL
    data.map {|info| User.new(info)}
  end
  
end 

##############  REPLY  #########################

class Reply 
  
  def self.find_all
    data = QuestionDatabase.instance.execute("SELECT * FROM replies")
    data.map {|info| Reply.new(info)}
  end
  
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    data.map {|info| Reply.new(info)}
  end
  
  def self.find_by_user_id(author_id)
    data = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    data.map {|info| Reply.new(info)}
  end 
  

  def self.find_by_question_id(questions_id)
    data = QuestionDatabase.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        replies
      WHERE
        questions_id = ?
    SQL
    data.map {|info| Reply.new(info)}
  end 

  attr_accessor :body
  attr_reader :id, :author_id, :questions_id, :parent_reply_id
  
  def initialize(options)
    @id = options['id']
    @body = options['body'] 
    @questions_id = options['questions_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
  end
  
  
  def author 
    User.find_by_id(@author_id)
  end 
  
  
  def question 
    Question.find_by_id(@questions_id)
  end 
  
  def parent_reply 
    Reply.find_by_id(@parent_reply_id)
  end
  
  def child_replies
    data = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    data.map {|info| Reply.new(info)}
  end 
  
end 

############## Question FOLLOWS #############

class QuestionFollow
  
  def self.followers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows
      ON
        users.id = question_follows.author_id
      WHERE
        question_follows.questions_id = ?
    SQL
    data.map {|info| User.new(info)}
  end
  
  def self.followed_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions 
      JOIN
        question_follows
      ON
        questions.id = question_follows.questions_id
      WHERE
        question_follows.author_id = ?
    SQL
    data.map {|info| Question.new(info)}
  end 
  
  def self.most_followed_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows
      ON
        questions.id = question_follows.questions_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL
    data.map {|info| Question.new(info)}
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def self.find_all
    data = QuestionDatabase.instance.execute("SELECT * FROM question_follows")
    data.map {|info| QuestionFollow.new(info)}
  end
  
  attr_reader :id, :author_id, :questions_id
    
  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @author_id = options['author_id']
  end
  
end

class QuestionLike
  
  def self.likers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes
      ON
        users.id = question_likes.author_id
      WHERE
        question_likes.questions_id = ?
    SQL
    data.map {|info| User.new(info)}
  end
  
  def self.num_likes_for_question_id(question_id)
    QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(question_likes.questions) AS likes
      FROM
        questions
      RIGHT JOIN
        question_likes
      ON
        questions.id = question_likes.questions_id
      WHERE
        question_likes.questions_id = ?
    SQL
  end
  
  def self.liked_questions_for_user_id(user_id)
    QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        users.id, COUNT(question_likes.questions_id) AS questions_liked
      FROM
        users
      JOIN
        question_likes
      ON
        users.id = question_likes.author_id
      WHERE
        users.id = ?
      GROUP BY
        users.id
      ORDER BY
        COUNT(question_likes.questions_id) DESC
    SQL
  end
  
  def self.most_liked_questions(n)
    QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = question_likes.questions_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL
  end
  
  def self.find_all
    data = QuestionDatabase.instance.execute("SELECT * FROM question_likes")
    data.map {|info| QuestionLike.new(info)}
  end
  
  attr_reader :id, :author_id, :questions_id
    
  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @author_id = options['author_id']
  end
end


