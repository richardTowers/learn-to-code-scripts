# What this script does:
# * Gets a list of students from our google forms and populates them with everything we know about them (e.g. which sessions they can do, whether they're a returning student)
# * Gets a list of the scheduled rooms, and adds data about how many people the room can accommodate
# * Assigns students to rooms so that:
#   * Students only attend sessions they said they could attend
#   * Rooms don't have more people than they can hold
#   * Sessions are mostly "lesson 1", "lesson 2" or "lesson 3".
#   * Students can mostly attend all three sessions

class Session
  attr_reader :name, :room, :capacity
  def initialize(name, room, capacity)
    @name = name
    @room = room
    @capacity = capacity
  end
end

class Student
  attr_reader :email, :type, :job_role, :experience, :availability
  def initialize(email, type, job_role, experience, availability)
    @email = email
    @type = type
    @job_role = job_role
    @experience = experience
    @availability = availability
  end
end

room_sizes = {
  "blue" => 10,
  "orange" => 10,
  "social space" => 15,
}

require 'csv'

attendees_raw = CSV.read("downloads/Learn to code at GDS (Q2) (Responses) - Form responses 1.csv")
student_availability_raw = CSV.read("downloads/Learn to code at GDS (Q2) (Responses) - Form responses 2.csv")
session_rooms = CSV.read("downloads/Rooms for learn to code Q2 - Sheet1.csv").map{|row|row.map{|cell|cell.strip}}

availability = Hash[student_availability_raw
  .select{|row| row[1].include? "@"}
  .map{|row| [row[1], (row[2]||'').split(',').map{|x|x.strip}]}]

students = attendees_raw.select { |row|
  row[2] == "new student" || row[2] == "returning student from the Q1 pilot lessons"
}.map { |row|
  Student.new(row[1], row[2], row[3], row[4], availability[row[1]])
}

baduns = students.select {|s| !s.availability.nil? && s.availability != [] && s.type == "new student"}.reject { |s|
  (s.availability.include?('12th AM') || s.availability.include?('13th PM') || s.availability.include?('14th AM')) &&
  (s.availability.include?('15th AM') || s.availability.include?('15th PM')) &&
  (s.availability.include?('19th PM') || s.availability.include?('27th PM'))
}

baduns.each { |s|
  printf "#{s.email}	"
  session_rooms.select{|x|x[1] == "social space"}.each{ |x|
    if s.availability.include?(x[0])
      printf "Yes	"
    else
      printf "No	"
    end
  }
  puts
}

