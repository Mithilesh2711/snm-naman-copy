class TrnGeoLocation < ApplicationRecord
  require 'roo'
  def self.to_tracklocations
    attributes = %w{gc_dates gcduty gc_name gc_address gc_local_time gc_latitude gc_longitude}
    attributes1 = %w{DATE TYPE USER LOCATION TIME LATITUDE LOGNTITUDE}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes1
      all.each do |user|
                 empob = to_employee_name(user.gc_user_id.to_i)
                  if empob!=nil
                     user.gc_name = empob
                  else
                     user.gc_name = ''
                  end

        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
end

def self.to_employee_name(salesid)
  salesman = nil
  issalesman = MstEmployee.select('emp_name').where("emp_compcode=? AND id=?",$compcodes,salesid).first
  if issalesman
      salesman = issalesman.emp_name
  end
  return salesman
end

def self.open_spreadsheet(file)
  case File.extname(file.original_filename)
  when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
  else raise "Unknown file type: #{file.original_filename}"
  end
end
end
