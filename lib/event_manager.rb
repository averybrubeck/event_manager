require 'csv'
puts 'Event Manager Initialized!'

begin
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)
  contents.each do |row|
    name = row[:first_name]
    zip = row[:zipcode]
    puts "#{name}, #{zip}"
  end
rescue Errno::ENOENT
  puts 'File Not Found'
end