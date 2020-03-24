require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :grade, :name, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade

  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id    INTEGER PRIMARY KEY,
        name  TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    
    # binding.pry
    id, name, grade = row
    Student.new(id, name, grade)
  end

  def save
    if self.id
      # update record in db
      self.update
    else
      # persist to db
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      # assign student id
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # def self.new_from_db(row)
  #   new_student = Student.new
  #   id, name, grade = row
  #   new_student.id = id
  #   new_student.name = name
  #   new_student.grade = grade
  #   new_student
  # end

  # def name=(name)
  #   # set self.name
  #   # update database record
  # end

end
