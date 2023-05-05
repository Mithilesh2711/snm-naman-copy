class TrnElectricConsumption < ApplicationRecord

    def self.to_generate_electric
        attributes = %w{SewadarCode SewadarName  MeterNo CurrentReading PreviousReading Consumption Amount(Rs.) Remarks}
        attributes1 = %w{ec_sewdarcode sw_sewadar_name  sw_meterno curreading lastreading consumption tamounts  ec_reamrk}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            if all.length >0
                if $eclectdata.length >0
                    $eclectdata.each do |user|
                    csv << attributes1.map{ |attr| user.send(attr) }
                    end
                end
            end    
        end
    end

end
