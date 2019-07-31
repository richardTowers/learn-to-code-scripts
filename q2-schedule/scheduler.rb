# What this script does:
# * Gets a list of students from our google forms and populates them with everything we know about them (e.g. which sessions they can do, whether they're a returning student)
# * Gets a list of the scheduled rooms, and adds data about how many people the room can accommodate
# * Assigns students to rooms so that:
#   * Students only attend sessions they said they could attend
#   * Rooms don't have more people than they can hold
#   * Sessions are mostly "lesson 1", "lesson 2" or "lesson 3".
#   * Students can mostly attend all three sessions


# Data I'm missing at the moment:
# Which rooms do these sessions happen in?
#   12th AM
#   13th PM
#   14th AM
#   15th AM
#   15th PM
#   19th AM
#   19th PM
#   23rd AM
#   23rd PM
#   (Bank Holiday week) 27th AM
#   27th PM
#   27th AM
#   28th AM
#   28th PM
#   29th AM
#   29th PM
#   30th AM
#   30th PM

class Session
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

class Student
  attr_reader :email, :type, :job_role, :experience
  def initialize(email, type, job_role, experience, availability)
    @email = email
    @type = type
    @job_role = job_role
    @experience = experience
    @availability = availability
  end
end

require 'csv'

attendees_raw = CSV.read("downloads/Learn to code at GDS (Q2) (Responses) - Form responses 1.csv")
student_availability_raw = CSV.read("downloads/Learn to code at GDS (Q2) (Responses) - Form responses 2.csv")

# Availability should be a map of email to list of lessons
availability = Hash[student_availability_raw
  .select{|row| row[1].include? "@"}
  .map{|row| [row[1], (row[2]||'').split(',').map{|x| Session.new(x)}]}]

students = attendees_raw.select { |row|
  row[2] == "new student" || row[2] == "returning student from the Q1 pilot lessons"
}.map { |row|
  Student.new(row[1], row[2], row[3], row[4], availability[row[1]])
}

