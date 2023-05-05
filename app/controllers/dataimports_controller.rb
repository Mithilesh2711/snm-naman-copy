class DataimportsController < ApplicationController
  before_action :require_login
 
  #skip_before_action :verify_authenticity_token, :only=> [:index]
  def index
    @compcodes  =  session[:loggedUserCompCode]
    @logedId    =  session[:autherizedUserId]
    @xLoc       =  session[:autherizedLoc]
  end
  
  def create
  @compcodes  = session[:loggedUserCompCode]
  $compcodes  = @compcodes
  isFlags     = true
 # process_update_sewadar(@compcodes)
 #die
 #DIE
 # begin
   if params[:file]!=nil && params[:file]!=''    
      #$isimport ="zone"
      $isimport ="sewadarrevsied"
      ############### IMPORT CUSTOMER & PRODUCT DATA ITEMS#############
      if $isimport == 'zone'
         # if  MstZone.import(params[:file])
          if  MstZone.process_zone_incharge(params[:file])
            flash[:error] =  "You have saved successfully "+(($xcount.to_s.length.to_i >0 ) ? $xcount.to_s : '0' )+" record(s)!"
            isFlags = true
            session[:isErrorhandled] = nil
          end
      elsif $isimport == 'sewadarrevsied'
         # if  MstZone.import(params[:file])
          if  MstSewadar.import(params[:file])
            flash[:error] =  "You have saved successfully "+(($xcount.to_s.length.to_i >0 ) ? $xcount.to_s : '0' )+" record(s)!"
            isFlags = true
            session[:isErrorhandled] = nil
          end
      end
     ############### END IMPORT CUSTOMER & PRODUCT DATA ITEMS#############
   end
 
 if !isFlags
  session[:postedpamams] = params
  session[:isErrorhandled] = 1
 else
   session[:postedpamams] = nil
   session[:isErrorhandled] = nil
 end
# rescue Exception => exc
#      flash[:error] =   "#{exc.message}"
#      session[:isErrorhandled] = 1
#  end
 redirect_to "#{root_url}"+"dataimports"
end

  def process_update_sewadar(compcode)
  kc = 0
  sd = 0
  kb = 0
  qf  = 0
  ofc = 0
  ps  = 0
  exp = 0
  fm  = 1
  if sd.to_i == 1
    seobjs = MstSewadar.where("sw_compcode =?",compcode).order("id ASC")
    if seobjs.length >0
      seobjs.each do |newsw|
         my_fill_sewdar(compcode,newsw.id,newsw.sw_revisedcode)
      end
    end
  end
  
  if kc.to_i == 1
      kycobj = MstSewadarKyc.where("sk_compcode = ? ",compcode).order("id ASC")
      if kycobj.length >0
        kycobj.each do |newkyc|
          my_fill_kyc(compcode,newkyc.id,newkyc.sk_revisedcode)
        end
      end
  end
  

  if kb == 1
     kybk = MstSewadarKycBank.where("skb_compcode = ?",compcode).order("id ASC")
    if kybk.length >0
      kybk.each do |nebk|
        my_fill_bank(compcode,nebk.id,nebk.skb_revisedcode)
      end
      
    end
  end
  
  if qf == 1
    qlobj = MstSewadarKycQualification.where("skq_compcode = ? ",compcode).order("id ASC")
      if qlobj.length >0
          qlobj.each do |neqlf|
            my_fill_qualif(compcode,neqlf.id,neqlf.skq_revisedcode)
          end       
      end
  end
  
if ofc.to_i == 1
    ofcobj  = MstSewadarOfficeInfo.where("so_compcode = ? ",compcode).order("id ASC")
    if ofcobj.length >0
      ofcobj.each do |newof|
        my_fill_office(compcode,newof.id,newof.so_revisedcode)
      end
    end
   
end ### supicious

 if ps.to_i == 1
  
    kycobj = MstSewadarPersonalInfo.where("sp_compcode = ? ",compcode).order("id ASC")
    if kycobj.length >0
        kycobj.each do |newps|
          my_fill_personal(compcode,newps.id,newps.sp_revisedcode)
        end
    end
 end

 if exp.to_i == 1
    kycobj = MstSewadarWorkExperience.where("swe_compcode = ? ",compcode).order("id ASC")
    if kycobj.length >0
        kycobj.each do |exp|
          my_fill_experience(compcode,exp.id,exp.swe_revisedcode)
        end
    end
 end
 
 if fm.to_i == 1
    kycobj = MstSewdarKycFamilyDetail.where("skf_compcode = ?",compcode).order("id ASC")
    if kycobj.length >0
       kycobj.each do |fmls|
           my_fill_family(compcode,fmls.id,fmls.skf_revisedcode)
       end
    end
 end
 
end

 def my_fill_sewdar(compcode,id,revisecode)
  seobjs = MstSewadar.where("sw_compcode =? AND id = ?",compcode,id).first
  if seobjs
    seobjs.update(:sw_sewcode=>revisecode)
  end
end

def my_fill_kyc(compcode,id,revisecode)
  kycobj = MstSewadarKyc.where("sk_compcode = ? AND id = ?",compcode,id).first
  if kycobj
    kycobj.update(:sk_sewcode=>revisecode)
  end
end

def my_fill_bank(compcode,id,revisecode)
  kycobj = MstSewadarKycBank.where("skb_compcode = ? AND id = ?",compcode,id).first
  if kycobj
     kycobj.update(:sbk_sewcode=>revisecode)
  end  
end

def my_fill_qualif(compcode,id,revisecode)
  kycobj = MstSewadarKycQualification.where("skq_compcode = ? AND id = ?",compcode,id).first
  if kycobj
    kycobj.update(:skq_sewcode=>revisecode)
  end
end

def my_fill_office(compcode,id,revisecode)
  kycobj = MstSewadarOfficeInfo.where("so_compcode = ? AND id = ?",compcode,id).first
  if kycobj
     kycobj.update(:so_sewcode=>revisecode)
  end
end

def my_fill_personal(compcode,id,revisecode)
  kycobj = MstSewadarPersonalInfo.where("sp_compcode = ? AND id = ?",compcode,id).first
  if kycobj
    kycobj.update(:sp_sewcode=>revisecode)
  end
end

def my_fill_experience(compcode,id,revisecode)
  kycobj = MstSewadarWorkExperience.where("swe_compcode = ? AND id = ?",compcode,id).first
  if kycobj
     kycobj.update(:swe_sewcode=>revisecode)
  end
end
def my_fill_family(compcode,id,revisecode)
  kycobj = MstSewdarKycFamilyDetail.where("skf_compcode = ? AND id = ?",compcode,id).first
  if kycobj
     kycobj.update(:skf_sewcode=>revisecode)
  end
end

end
