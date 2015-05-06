require_relative 'questions_database.rb'

class Model
  def self.all
    raw_data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    objects = []
    raw_data.each { |row| objects << self.new(row) }
    objects
  end

  def self.find_by_id(id)
    raw_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    raise "Two rows with same ID found!" if raw_data.size > 1
    self.new(raw_data.first)
  end

  def save
    c_names = instance_variables.map { |name| name.to_s[1..-1] }
    name_string = "(#{c_names[1..-1].join(', ')})"
    value_string = "("
    (c_names.size-2).times { value_string << "?, " }
    value_string += " ?)"

    col_string = c_names.drop(1).join(' = ?, ') + ' = ?'

    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *params[0..-2])
        INSERT INTO
          #{self.class.table_name} #{name_string}
        VALUES
          #{value_string}
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, *params)
        UPDATE
          #{self.class.table_name}
        SET
          #{col_string}
        WHERE
          id = ?
      SQL
    end
  end

end
