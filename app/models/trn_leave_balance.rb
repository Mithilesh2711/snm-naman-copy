class TrnLeaveBalance < ApplicationRecord
    def self.leave_summary_data
        headers5    = ["Leave Summary","","","",""]
        headers6    = ["As on Date : "+$asondated.to_s,"","",""]   
      
        attributes   = %w{SewadarCode ReferenceCode SewadarName Category Department EL CL SL CO OD}
        attributes1  = %w{sw_sewcode sw_oldsewdarcode sw_sewadar_name categroy department elcb clcb slcb cocb odcb}  
         pitems  = []
          if all.length >0
              if $mysewobj.length
                $mysewobj.each do |newregister|
                    pitems.push newregister
                end
              end
        end
        # subobj   = TrnPrawnTable.select(isselect).all
        # if subobj.length >0
        #    subobj.each do |mysub|
        #        pitems.push mysub
        #    end
        # end
        tworkingday = 0
        tpaidleave  = 0
        thalfleave  = 0
        tweeklyoff  = 0
        tabsent     = 0
        tgrossma    = 0
       
       CSV.generate(:headers=> true) do |csv|
            csv << headers5
            csv << headers6
             csv << attributes
              if pitems.length >0
                   pitems.each do |newsalry|
                       csv << attributes1.map{ |attr| newsalry.send(attr) }
                   end
              end
         end
   end
    def self.open_spreadsheet(file)
        case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
        when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
        when ".xl" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
        else raise "Unknown file type: #{file.original_filename}"
        end
      end
      private
 def self.formatteddate(dates)
      newdate = ''
      if dates!=nil && dates!=''
           dts    = Date.parse(dates.to_s)
           newdate = dts.strftime("%d-%b-%Y")
      end
      return newdate
 end

 private
   def self.currencyformatted(amt)
        amts = 0
        if amt!=nil && amt!=''
          amts = amt.to_f.round(0)
        end
        return amts
   end
end
