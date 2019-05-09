require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: id=nil, name: 'name', breed: 'breed' )
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        breed TEXT,
        name, TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP table dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      #binding.pry
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    #what what what to bring from teh dead
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_student = self.new(name: row[1], breed:row[2], id:row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_or_create_by(attr)
    dog_rows = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr[:name], attr[:breed])
    if !dog_rows.empty?
      row = dog_rows[0]
      dog = self.new(name: row[1], breed: row[2], id: row[0])
    else
      dog = self.create(attr)
    end
  end
end
