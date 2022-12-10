require 'csv'
require "pry"

csv = CSV.read("table.csv")
tables = Array.new
t = Array.new
csv.each do |row|
  if !row[0].nil?
    t << row
    if row[0] == "updated_at"
      tables << t
      t = Array.new
    end
  end
end
tables[0] = tables[0][1..-1]
File.open("tables.txt", 'w') do |file|
  tables.each do |table|
    next if table.length < 6
    first = "CREATE TABLE #{table[0][1]} (\n"
    file.write(first)
    table[6..-1].each do |row|
      name = row[0]
      type = row[2]
      type += "(#{row[3]})"          if !row[3].nil?
      null = " NOT NULL"             if !row[6].nil?
      default = " " + row[7]         if !row[7].nil?
      cascade = " ON DELETE CASCADE" if row[9] == "cascade"
      column  = "#{name} #{type}#{null}#{default}#{cascade},\n"
      file.write(column)
    end
    uniques = "\n"
    table[4][1].scan(/\[(.*?)\]/).map{|unique_pair| uniques += "UNIQUE (#{unique_pair[0]}),\n" }
    uniques[-2] = ''
    file.write("#{uniques})#{table[1][2]};\n\n")
  end
end



