class MstLedger < ApplicationRecord
  def self.to_generate_members
      attributes = %w{MemberCode Name PanNo AdharNo PersonalEmail OfficialEmail MobileNo DateofBirth Address PinNo Designation}
      attributes1 = %w{lds_membno lds_name panno adharno email offemail mobileno lds_dob lds_address lds_pin mydesignation}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
        if all.length >0
          if $printedexcel.length >0
            $printedexcel.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
          end
        end
      end
  end
  def self.to_get_sewacard_listed
    attributes = %w{SewadarCode 	Name 	Department }
    attributes1 = %w{sw_sewcode sw_sewadar_name department}
    headers    = ["Sewsara Card List","","","",""]
    headers2    = ["Category : "+$categiry_name,"","","",""]
    CSV.generate(:headers=> true) do |csv|
      csv << headers
    csv << headers2
      csv << attributes
        if all.length >0
          if $voucherdata.length >0
                $voucherdata.each do |user|                 
                   csv << attributes1.map{ |attr| user.send(attr) }
              end
          end
        end
    end
  end

end
