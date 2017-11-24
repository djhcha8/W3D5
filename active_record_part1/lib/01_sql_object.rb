require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    
    @columns = data.first.map { |col| col.to_sym }
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
      
      define_method("#{column}=" ) do |value|
        self.attributes[(column)] = value
      end
    end
    
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name || name.tableize
  end

  def self.all
    # ...
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    
    self.parse_all(all)
  end

  def self.parse_all(results)
    # ...
    results.map {|result| self.new(result)}
  end

  def self.find(id)
    # ...
    # self.all.find { |col| col.id == id }
    all = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    SQL
    
    self.parse_all(all).first
  end

  def initialize(params = {})
    # ...
    params.each do |attr_name, value|
      sym_name = attr_name.to_sym
      
      if self.class.columns.include?(sym_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    @attributes.values
  end

  def insert
    # ...
    col_names = self.class.columns.drop(1).join(", ")
    question_marks = (["?"] * self.class.columns.drop(1).length).join(", ")
    new_values = self.attribute_values
    DBConnection.execute(<<-SQL, new_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    
    self.id = self.class.all.last.id
  end

  def update
    # ...
    new_values = self.attribute_values
    col_names = self.class.columns.map {|col| "#{col} = ?"}.join(', ')
    DBConnection.execute(<<-SQL, new_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    # ...
    self.id == nil ? self.insert : self.update
  end
end
