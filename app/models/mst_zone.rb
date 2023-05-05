class MstZone < ApplicationRecord
 def self.to_generate_zone
      attributes = %w{ZoneCode ZoneNumber ZoneName ZonalIncharge InchargeMobileNo AdditionalContact LandLineNo Address SNMEmail PersonalEmail ZoneOffice}
      attributes1 = %w{zn_zonecode zn_number zn_name zn_incharge zn_inchmobile zn_addcontact zn_landlineno zn_inchargaddress zn_inchargesnm_email zn_zone_email zn_zoneoffice}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end

 def self.import(file)
     files = IO.read(file).force_encoding("ISO-8859-1").encode("utf-8", :replace=> nil)
     $xcount = 0
    if $isimport == 'zone'      
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]         
          zonenename  =  (row["ZoneName"].to_s.length >0 )? row["ZoneName"] : ''
          zn_number   =  (row["ZoneNo"].to_s.length >0 )? row["ZoneNo"] : ''
          distname    =  (row["DistrictZone"].to_s.length >0 )? row["DistrictZone"] : ''
          branchname  =  (row["Branches"].to_s.length >0 )? row["Branches"] : ''
          branchaddss = "" #(row["ZoneAddress"].to_s.length >0 )? row["ZoneAddress"] : ''
          zocodes     =  creates_zone($compcodes,zonenename,zn_number)
         if zocodes
           distcode =  creates_disrict_zone($compcodes,zocodes,distname)
           if distcode
             creates_branch_disrict_zone($compcodes,zocodes,distcode,branchname,branchaddss)
           end
           $xcount +=1
        end
    end
  end

end

 private
 def self.creates_zone(compcode,zonenename,zn_number)
   zonenename   = zonenename.to_s.strip
   @compcodes   = compcode
   zoncode      = ""
   zonobj = MstZone.where("zn_compcode = ? AND LOWER(zn_name) = ? ",compcode,zonenename.to_s.downcase)
    if zonobj.length >0
      zoncode = zonobj[0].zn_zonecode
    else
        zoncode = mygenerate_zones_series
        zonobjs = MstZone.new(:zn_compcode=>compcode,:zn_zonecode=>zoncode,:zn_number=>zn_number,:zn_name=>zonenename)
        zonobjs.save
    end
    return zoncode
 end
 private
 def self.creates_disrict_zone(compcode,zonecode,distname)
   distnames    = distname.to_s.strip
   @compcodes   = compcode
   distcode     = ""
   zonobj = MstZoneDistrict.where("zd_compcode = ? AND zd_zonecode = ?  AND LOWER(zd_name) = ?",compcode,zonecode,distnames.to_s.downcase)
    if zonobj.length >0
      distcode = zonobj[0].zd_distcode
    else
        distcode = mygenerate_district_zones_series
        zonobjs  = MstZoneDistrict.new(:zd_compcode=>compcode,:zd_zonecode=>zonecode,:zd_distcode=>distcode,:zd_name=>distnames)
        zonobjs.save
    end
    return distcode
 end

 private
 def self.creates_branch_disrict_zone(compcode,zonecode,distcode,branchname,branchaddss)
   branchnames  = branchname.to_s.strip
   branchaddss = branchaddss.to_s.strip
   @compcodes   = compcode
   branchcode   = ""
   zonobj = MstBranch.where("bch_compcode = ? AND bch_zonecode = ? AND bch_districtcode = ? AND LOWER(bch_branchname) = ?",compcode,zonecode,distcode,branchnames.to_s.downcase)
    if zonobj.length >0
    else
        branchcode = mygenerate_branch_series
        zonobjs  = MstBranch.new(:bch_compcode=>compcode,:bch_branchcode=>branchcode,:bch_zonecode=>zonecode,:bch_districtcode=>distcode,:bch_branchname=>branchnames,:bch_address=>branchaddss)
        zonobjs.save
    end
    return branchcode
 end

private
def self.mygenerate_zones_series
  prefixobj    = find_common_prefix('Zone')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstZone.select("zn_zonecode").where(["zn_compcode = ? AND zn_zonecode<>''", $compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.zn_zonecode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode    = @isCode.to_i + 1
  newlength      = @sumXOfCode.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = myserial_global_number(genleth)
  @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
  myprefix  = ""
  if prefixobj
      myprefix = prefixobj.sn_prefix
  end
  if myprefix !=nil && myprefix !=''
    myprefix = myprefix.to_s+@sumXOfCode.to_s
  else
    myprefix = @sumXOfCode
  end
  return myprefix

end

def self.myserial_global_number(lgth)
     chracters = ""
    for i in 1..lgth
        chracters +="0"
    end
    return chracters

end

private
def self.mygenerate_district_zones_series
  prefixobj    = find_common_prefix('ZoneDsitrict')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstZoneDistrict.select("zd_distcode").where(["zd_compcode = ? AND zd_distcode<>''", $compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.zd_distcode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode2    = @isCode.to_i + 1
  newlength      = @sumXOfCode2.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = myserial_global_number(genleth)
  @sumXOfCode2    = zeroseires.to_s+@sumXOfCode2.to_s
  myprefix  = ""
  if prefixobj
      myprefix = prefixobj.sn_prefix
  end
  if myprefix !=nil && myprefix !=''
    myprefix = myprefix.to_s+@sumXOfCode2.to_s
  else
    myprefix = @sumXOfCode2
  end
  return myprefix

end

private
def self.mygenerate_branch_series
  prefixobj    = find_common_prefix('Branch')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstBranch.select("bch_branchcode").where(["bch_compcode = ? AND bch_branchcode<>''", $compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.bch_branchcode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode3    = @isCode.to_i + 1
  newlength      = @sumXOfCode3.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = myserial_global_number(genleth)
  @sumXOfCode3    = zeroseires.to_s+@sumXOfCode3.to_s
  myprefix  = ""
  if prefixobj
      myprefix = prefixobj.sn_prefix
  end
  if myprefix !=nil && myprefix !=''
    myprefix = myprefix.to_s+@sumXOfCode3.to_s
  else
    myprefix = @sumXOfCode3
  end
  return myprefix

end



private
def self.find_common_prefix(sn_type)
    compcode =  @compcodes
    msobj    =  MstSerialNumber.where("sn_compcode =? AND sn_type = ?",compcode,sn_type).first
    return msobj
end
def self.open_spreadsheet(file)
  case File.extname(file.original_filename) 
  when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
  else raise "Unknown file type: #{file.original_filename}"
  end
end

private
def self.process_zone_incharge(file)
      compcodes = $compcodes
     $xcount = 0
    if $isimport == 'zone'
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
          row               = Hash[[header, spreadsheet.row(i)].transpose]
          zn_zonecode       =  (row["zn_zonecode"].to_s.length >0 )? row["zn_zonecode"] : ''
          zn_number         =  (row["zn_number"].to_s.length >0 )? row["zn_number"] : ''
          zn_incharge       =  (row["zn_incharge"].to_s.length >0 )? row["zn_incharge"] : ''
          zn_inchargaddress =  (row["zn_inchargaddress"].to_s.length >0 )? row["zn_inchargaddress"] : ''
          zn_zone_email     =  (row["zn_zone_email"].to_s.length >0 )? row["zn_zone_email"] : ''
          zn_landlineno     =  (row["zn_landlineno"].to_s.length >0 )? row["zn_landlineno"] : ''
          zn_inchmobile     =  (row["zn_inchmobile"].to_s.length >0 )? row["zn_inchmobile"] : ''
          zn_name           =  (row["zn_name"].to_s.length >0 )? row["zn_name"] : ''
          zocodes            =  new_creates_zone(compcodes,zn_number,zn_incharge,zn_inchargaddress,zn_zone_email,zn_landlineno,zn_inchmobile,zn_zonecode,zn_name)
         if zocodes           
           $xcount +=1
        end
    end
  end
end

private
 def self.new_creates_zone(compcodes,zn_number,zn_incharge,zn_inchargaddress,zn_zone_email,zn_landlineno,zn_inchmobile,zn_zonecode,zn_name)
  # zoneneno     = zn_number.to_s.strip
  @zn_inchargaddress  = zn_inchargaddress
  @zn_zone_email      = zn_zone_email
   zoncode      = ""
   #zonobj = MstZone.where("zn_compcode = ? AND LOWER(zn_number) = ? ",compcodes,zoneneno.to_s.downcase).first
   zonobj = MstZone.where("zn_compcode = ? AND zn_zonecode = ? ",compcodes,zn_zonecode).first
    if zonobj
        zoncode = zonobj.zn_zonecode
        zonobj.update(:zn_incharge=>zn_incharge,:zn_number=>zn_number,:zn_name=>zn_name,:zn_landlineno=>zn_landlineno,:zn_inchmobile=>zn_inchmobile)

    else
         # zoncode = mygenerate_zones_series
         # zonobjs = MstZone.new(:zn_incharge=>zn_incharge,:zn_inchargaddress=>zn_inchargaddress,:zn_zone_email=>zn_zone_email,:zn_landlineno=>zn_landlineno,:zn_inchmobile=>zn_inchmobile)
         # zonobjs.save
    end
    return zoncode
 end


end
