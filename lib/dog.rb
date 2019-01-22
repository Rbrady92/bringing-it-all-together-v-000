class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
                        id INTEGER PRIMARY KEY,
                        name TEXT,
                        breed TEXT)"
                      )
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2])
    dog.save
  end

  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map {|row| self.new_from_db(row)}
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create([nil, name, breed])
    end

    new_dog

    # if dog.empty?
    #   new_dog = self.create(name: name, breed: breed)
    #   new_dog
    # else
    #   #new_dog = self.new_from_db(dog)
    #   dog.map {|row| self.new_from_db(row)}.first
    # end
  end

  def self.update 
    DB[:conn],execute("UPDATE dogs SET name = ?, breed = ?, id = ?", self.name, self.breed, self.id)
  end 


end
