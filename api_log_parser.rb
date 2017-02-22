require 'csv'

i = 0
lines = []
CSV.foreach('api-logs.csv', encoding: 'UTF-8') do |row|
  begin
    j = JSON.parse(row[1])
    cop = j['certOfPreferenceNatKey']
    dthp = j['displacedPreferenceNatKey']
    if cop || dthp
      cop ||= ''
      dthp ||= ''
      next if cop.include?('test luk') || dthp.include?('test luk')
      next if cop.include?('LUke,Lim') || dthp.include?('LUke,Lim')
      dob1 = cop.present? ? cop.split(',').last.split('-') : []
      dob2 = dthp.present? ? dthp.split(',').last.split('-') : []
      if %w[01 12].include?(dob1[1]) || %w[01 12].include?(dob2[1])
        obj = {
          primary: j['primaryApplicant'].to_s,
          cop: cop.present? ? cop : 'none',
          dthp: dthp.present? ? dthp : 'none',
          id: j['id'],
        }
        lines.push(obj)
      end
    end
  rescue => e
    puts "uh oh - #{e.message}"
  end
  i += 1
end;

csv_string = CSV.generate do |csv|
  csv << %w[
    cop
    dthp
    app_id
    primary
  ]

  lines.each do |line|
    csv_line = []
    csv_line << line[:cop]
    csv_line << line[:dthp]
    csv_line << line[:id]
    csv_line << line[:primary]
    csv << csv_line
  end
end;

File.open('apps.csv', 'w') { |file| file.write(csv_string) }
