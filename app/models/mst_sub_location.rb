class MstSubLocation < ApplicationRecord
  def self.to_generate_sublocation
      attributes = %w{Description Location}
      attributes1 = %w{sl_description locations}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             chobjs =  find_ho_location(user.sl_compcode,user.sl_locid)
             if chobjs
               user.locations = chobjs.hof_description
             end
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end

  private
def self.find_ho_location(compcode,locid)
  locobj   =  MstHeadOffice.where("hof_compcode =? AND id = ?",compcode,locid).first
  return locobj
end

end
