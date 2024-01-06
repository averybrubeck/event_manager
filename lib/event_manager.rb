puts 'Event Manager Initialized!'

begin
  lines = File.readlines('event_attendees.csv')
  lines.each_with_index do |line, index|
    next if index.zero?
    columns = line.split(',')
    name = columns[2]
    puts name
  end
rescue Errno::ENOENT
  puts 'File Not Found'
end