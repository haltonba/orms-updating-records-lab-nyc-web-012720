require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize (id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create (name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db (row)
    student_new = Student.new(row[0], row[1], row[2])
    student_new
  end

  def self.find_by_name (name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name).map {|row| new_from_db(row)}.first
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ?, id = ?;
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end
end
