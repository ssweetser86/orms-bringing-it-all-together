require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        self.id = id
        self.name = name
        self.breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        return self
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"

        row = DB[:conn].execute(sql, id).first
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, name, breed)
        if dog.empty?
            self.create(name: name, breed: breed)
        else
            self.new_from_db(dog[0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql, name)
        !dog.empty? ? self.new_from_db(dog[0]) :  nil
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end