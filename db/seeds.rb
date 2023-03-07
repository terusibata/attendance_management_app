# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
User.create!(name:  "管理者アカウント",
  email:                 "admin@test.com",
  password:              "admintest",
  password_confirmation: "admintest",
  hire_date:             "2023-01-01",
  admin:                 true,
)
User.create!(name:  "従業員アカウント1",
  email:                 "user1@test.com",
  password:              "usertest1",
  password_confirmation: "usertest1",
  hire_date:             "2023-01-01",
  admin:                 false,
)
User.create!(name:  "従業員アカウント2",
  email:                 "user2@test.com",
  password:              "usertest2",
  password_confirmation: "usertest2",
  hire_date:             "2023-02-01",
  admin:                 false,
)
User.create!(name:  "従業員アカウント3",
  email:                 "user3@test.com",
  password:              "usertest3",
  password_confirmation: "usertest3",
  hire_date:             "2023-03-01",
  admin:                 false,
)

Attendance.create!(user_id: 1, work_day: "2023-03-01", start_time: "09:00:00", end_time: "17:00:00")
Attendance.create!(user_id: 1, work_day: "2023-03-02", start_time: "09:30:00", end_time: "16:00:00")
Attendance.create!(user_id: 1, work_day: "2023-03-03", start_time: "09:20:00", end_time: "18:00:00")
Attendance.create!(user_id: 1, work_day: "2023-03-04", start_time: "09:10:00", end_time: "17:40:00")
Attendance.create!(user_id: 1, work_day: "2023-03-05", start_time: "09:40:00", end_time: "19:30:00")
Attendance.create!(user_id: 1, work_day: "2023-03-06", start_time: "09:50:00", end_time: "18:10:00")

Attendance.create!(user_id: 2, work_day: "2023-03-01", start_time: "09:00:00", end_time: "17:00:00")
Attendance.create!(user_id: 2, work_day: "2023-03-02", start_time: "09:30:00", end_time: "16:00:00")
Attendance.create!(user_id: 2, work_day: "2023-03-03", start_time: "09:20:00", end_time: "18:00:00")
Attendance.create!(user_id: 3, work_day: "2023-03-04", start_time: "09:10:00", end_time: "17:40:00")
Attendance.create!(user_id: 3, work_day: "2023-03-05", start_time: "09:40:00", end_time: "19:30:00")
Attendance.create!(user_id: 3, work_day: "2023-03-06", start_time: "09:50:00", end_time: "18:10:00")

Break.create!(attendance_id: 1, start_time: "10:00:00", end_time: "11:00:00")
Break.create!(attendance_id: 1, start_time: "11:20:00", end_time: "11:30:00")
Break.create!(attendance_id: 2, start_time: "12:00:00", end_time: "12:30:00")
Break.create!(attendance_id: 3, start_time: "12:10:00", end_time: "12:30:00")
Break.create!(attendance_id: 4, start_time: "12:03:00", end_time: "12:40:00")
Break.create!(attendance_id: 5, start_time: "12:05:00", end_time: "12:50:00")
Break.create!(attendance_id: 6, start_time: "12:06:00", end_time: "12:60:00")
