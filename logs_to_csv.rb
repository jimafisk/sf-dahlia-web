require 'csv'

lines = []
File.open('shorterlog.log').each do |line|
  hash = eval(line.split(" - -   Parameters: ").last)
  hash['timestamp'] = line.slice(12,32)
  lines << hash
end

idx = 0
lines = lines.select do |line|
  idx += 1
  application = line['application']
  applicant = application['primaryApplicant']
  next_line = lines[idx]
  key1 = application['certOfPreferenceNatKey'].to_s
  key2 = application['liveInSfPreferenceNatKey'].to_s
  key3 = application['workInSfPreferenceNatKey'].to_s
  if (key1 || key2 || key3) && (key1.include?('-0') || key2.include?('-0') || key3.include?('-0'))
    if applicant and next_line and next_line['application']
      natKey = "#{applicant['firstName']},#{applicant['lastName']},#{applicant['dob']}"
      nextApplicant = next_line['application']['primaryApplicant']
      natKeyNext = "#{nextApplicant['firstName']},#{nextApplicant['lastName']},#{nextApplicant['dob']}"
      natKey != natKeyNext
    else
      true
    end
  end
end;

csv_string = CSV.generate do |csv|
  csv << %w[
    applicationID
    timestamp
    status
    phone
    email
    primaryApplicantNatKey
    certOfPreferenceNatKey
    liveInSfPreferenceNatKey
    workInSfPreferenceNatKey
  ]
  lines.each do |line|
    application = line['application']
    applicant = application['primaryApplicant']
    csv_line = []
    csv_line << application['id']
    csv_line << line['timestamp']
    csv_line << application['status']
    csv_line << applicant['phone']
    csv_line << applicant['email']
    csv_line << "#{applicant['firstName']},#{applicant['lastName']},#{applicant['dob']}"
    csv_line << application['certOfPreferenceNatKey']
    csv_line << application['liveInSfPreferenceNatKey']
    csv_line << application['workInSfPreferenceNatKey']
    csv << csv_line
  end
end;

File.open('brighton_apps.csv', 'w') { |file| file.write(csv_string) }


#
#
# 1. if the column is filled in the CSV
# 2. if salesforce finds an appmember matching the natkey
# 3. if the preference is NOT filled currently in salesforce, fill it with found appmember
# 4. if it IS filled, leave it alone
#
# - last questions:
#  should we strip out "OK" DOBs so we're just sending "0"-pad ones?
#
#
#
