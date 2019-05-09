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

  def self.find_or_create_by(attr)
    binding.pry
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE ? = ?", attr.key, attr.value)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(dog_info[0], dog_info[1], dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end
end
