require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue StandardError => e
    "An error occured #{e.message} You can find your representatives by visiting
    www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thankyou_letter(id, form_letter)
  Dir.mkdir('Output') unless Dir.exist?('Output')
  filename = "Output/Thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phonenumber)
  if phonenumber.nil? || phonenumber.length < 10
    phonenumber = '0000000000'
  elsif phonenumber.length == 11 && phonenumber[0] == 1
    phonenumber.slice(1..-1)
  elsif phonenumber.length == 11 && phonenumber[0] != 1
    phonenumber = '0000000000'
  end
  phonenumber
end

def count_frequency(array)
  array.max_by { |a| array.count(a) }
end

puts 'EventManager initialized.'
contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
contents_size = CSV.read('event_attendees.csv').length
template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter
contents_size-=1
hour_of_day = Array.new(contents_size)
day_of_week = Array.new(contents_size)
j = 0
cal = { 0 => 'sunday', 1 => 'monday', 2 => 'tuesday', 3 => 'wednesday', 4 => 'thursday', 5 => 'friday', 6 => 'saturday' }
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  reg_date = row[:regdate]
  untidy_numbers = row[:homephone]
  phone_number = clean_phone_number(row[:homephone])
  i = ((row[0].to_f/contents_size)*100)
  puts "------------#{i.round(2)}%-----------"
  reg_date_to_print = DateTime.strptime(reg_date, '%m/%d/%y %H:%M')
  hour_of_day[j] = reg_date_to_print.hour
  day_of_week[j] = reg_date_to_print.wday
  j += 1

  form_letter = erb_template.result(binding)
  save_thankyou_letter(id, form_letter)
end
puts "Most Active Hour is : #{count_frequency(hour_of_day)}"
puts "Most Active Day is : #{cal[count_frequency(day_of_week)].capitalize}"