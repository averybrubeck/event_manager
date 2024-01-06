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

puts 'EventManager initialized.'
begin
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
rescue Errno::ENOENT
  puts 'File not found'
end

begin
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter
rescue Errno::ENOENT
  puts 'File not found'
end

contents.each do |row|
  id = row [0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thankyou_letter(id, form_letter)
end