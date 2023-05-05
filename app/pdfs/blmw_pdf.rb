# To change this template, choose Tools | Templates
# and open the template in the editor.

class BlmwPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,uRl,sewadarpersonal,empchecked,empkyc,empkycbank,empqualif,familydetail,empworkexp,empstatelist,empdistrict,hodlisted,empdepartment,monhlydata)
    super(:left_margin=>30,:right_margin=>15,:top_margin=>5,:page_size =>"A4",:background => "public/assets/img/HRD1.png" )
    @seawdarsobj          = seawdarsobj
    @compDetail           = compdetail
    @sewadarpersonal      = sewadarpersonal
    @empChecked           = empchecked
    @empkyc               = empkyc
    @empkycbank           = empkycbank
    @EmpKycQulifc         = empqualif
    @EmpKycFamily         = familydetail
    @EmpWorkExp           = empworkexp
    @EmpStatelist         = empstatelist
    @EmpDistrict          = empdistrict
    @Hodlisted            = hodlisted
    @EmpDepartment        = empdepartment
    @uRl2                 = uRl
    @monhlydata           = monhlydata
    @uRl                  = Rails.root.join "public"
    @logoSize             = 0.5   
    line_items
    
 end

 
 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
     ps = 1
  #     
  move_down 130

  departmentname     = ""
  hodnames           = ""
  if @Hodlisted
    
    hodnames = @Hodlisted.lds_name
  end
  if @EmpDepartment
 
    departmentname = @EmpDepartment.departDescription
  end
  dtyears = Date.today.strftime("%Y")
  ddated   = Date.today.strftime("%d-%b-%Y")
data21 = ([

  [{:content => ""},
  {:content => " "},
  {:content => ""}]

])

table([] + data21, :width => 522) do
style row(0), :border_width => 0 , :size => 10 , :align => :center

end

move_down 15
data22 = ([
  [{:content => ""},
  {:content => "Ref: SNM/HRD/"+@seawdarsobj.sw_sewcode.to_s+"/"+dtyears.to_s},
   {:content => "Date : "+ddated.to_s}]

])

table([] + data22, :width => 550)do
style row(0),  :border_width => 0
style column(0), :width     => 5, :align=>:left, :size => 12
style column(1), :width => 407
style column(2), :width     => 138, :size => 12
end

move_down 15
data23 =([
  [{:content => ""},
   {:content =>"TO WHOMSOEVER IT MAY CONCERN"},
   {:content => ""}]
])

table([] + data23, :width => 528) do
  style row(0), :border_width => 0 , :size => 12 , :align => :center
  style row(0).column(1), :font_style => :bold, :border_bottom_width => 1 , :width => 240
end



typeofx = ""
namex   = ""
if @seawdarsobj
 if @seawdarsobj.sw_gender == 'F'
     if @seawdarsobj.sw_maritalstatus == 'Y'
       typeofx = "W/O"
       namex   = @seawdarsobj.sw_husbprefix.to_s+". "+@seawdarsobj.sw_husbandname.to_s
     else
       typeofx = "D/O"
       namex   = @seawdarsobj.sw_father_prefix.to_s+". "+@seawdarsobj.sw_father_name
     end
 else
    typeofx = "S/O"
    namex   = @seawdarsobj.sw_father_prefix.to_s+". "+@seawdarsobj.sw_father_name
 end

end
statename    = ""
districtname = ""
if @EmpStatelist 
 statename = @EmpStatelist.sts_description 

end
if @EmpDistrict 
 districtname = @EmpDistrict.dts_description 
end
personaladdress = ""
if @sewadarpersonal
   
 personaladdress = @sewadarpersonal.sp_pres_houseaddress.to_s+(districtname ? ", "+districtname : '').to_s+(statename ? ", "+statename : '').to_s+(@sewadarpersonal.sp_pres_pincode ? ", "+@sewadarpersonal.sp_pres_pincode : '').to_s

end


typeofme2   = ""
if @seawdarsobj
  if @seawdarsobj.sw_gender.to_s == 'F'
       typeofme2 = "She"
  else     
      typeofme2 = "He"
  end
 
 end
 typeofx2   = ""
#  if @seawdarsobj
#   if @seawdarsobj.sw_gender == 'F'
#       if @seawdarsobj.sw_maritalstatus == 'Y'
#         typeofx2 = "Ms."
      
#       else
#         typeofx2 = "Ms."
        
#       end
#   else
#      typeofx2 = "Mr."
     
#   end

# end
monthsef  =  @monhlydata.length >0 ? @monhlydata[0].monthname.to_s : ''
monthyear =  @monhlydata.length >0 ? @monhlydata[0].pm_payyear.to_s : ''
move_down 15
data24 = ([
  [{:content => "#{Prawn::Text::NBSP*10}This is to certify that "+@seawdarsobj.sw_sewadar_prefix.to_s+". "+(@seawdarsobj ? @seawdarsobj.sw_sewadar_name.to_s.split(/ |\_|\-/).map(&:capitalize).join(" "): '' ).to_s+" "+typeofx.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" "+namex.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" is doing sewa at"" " +@compDetail.cmp_companyname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+", "+@compDetail.cmp_addressline1.to_s+" since "+formatted_date(@seawdarsobj.sw_joiningdate).to_s+". "+typeofme2.to_s+" is being paid Maintenance Allowance w.e.f. "+monthsef.to_s+", " +monthyear.to_s+" as under:-"},
    {:content => ""},
    {:content => ""}]
])
table([] + data24, :width => 558) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end

move_down 20

# 
tactual    = 0
tdeucts    = 0
tafterdect = 0

data26 = ([
  [{:content=>""},{:content => "Month & Year",:rowspan=>2}, {:content => "Gross M.A.\n(Rs.)",:rowspan=>2},{:content=>"Deductions\n(Rs.)",:colspan=>6},{:content => "Total Deductions\n(Rs.)",:rowspan=>2},{:content => " Net M.A.\n(Rs.)",:rowspan=>2},{:content=>""}],
  [{:content=>""},{:content => "LIC"}, {:content => "Health Insurance"},{:content => "Advance"},{:content => "TDS"},{:content=>"Building Maintenance"},{:content=>"Other Deductions"}],
    ])
    if @monhlydata.length >0
      @monhlydata.each do |newdata| 
      finalpaid =   newdata.pm_actbasic.to_f-(newdata.pm_totaldeduction.to_f).to_f
      tductcts  = newdata.pm_totaldeduction.to_f
      tactual += newdata.pm_actbasic.to_f
      tdeucts += tductcts.to_f
      tothers = newdata.pm_totaldeduction.to_f-(newdata.pm_ded_licemployee.to_f+newdata.pm_ded_healthsewdarpay.to_f+newdata.pm_ded_repaidadvance.to_f+newdata.pm_totaltds.to_f+newdata.pm_dedaccomodatamount.to_f).to_f
      tafterdect += finalpaid.to_f
        data26 += ([
            [{:content=>""},{:content => newdata.monthname.to_s+", "+newdata.pm_payyear.to_s}, {:content => currency_formatted(newdata.pm_actbasic).to_s},{:content=>newdata.pm_ded_licemployee.to_s},{:content=>newdata.pm_ded_healthsewdarpay.to_s},{:content=>newdata.pm_ded_repaidadvance.to_s},{:content=>newdata.pm_totaltds.to_s},{:content=>newdata.pm_dedaccomodatamount.to_s},{:content=>currency_formatted(tothers).to_s},{:content => currency_formatted(tductcts).to_s},{:content => currency_formatted(finalpaid).to_s},{:content=>""}],
          
          ])
      end
    
    end

# data26 += ([
#       [{:content => ""},{:content => currency_formatted(tactual).to_s},{:content => currency_formatted(tdeucts).to_s},{:content => currency_formatted(tafterdect).to_s}]

#     ])
    tactual    = 0
    tdeucts    = 0
    tafterdect = 0


table([] + data26, :width => 558) do
  style row(0..1).column(0..10), :size => 11 , :align => :center
  style row(0..1).column(0), :size => 10 , :align => :center , :width => 10
  style row(0..1).column(1), :size => 10 , :align => :center  , :width => 70
  style row(0..1).column(2), :size => 10 , :align => :center , :width => 60
  style row(0..1).column(3), :size => 10 , :align => :center , :width => 43
  style row(0..1).column(4), :size => 10 , :align => :center , :width => 52
  style row(0..1).column(5), :size => 10 , :align => :center , :width => 48
  style row(0..1).column(6), :size => 10 , :align => :center , :width => 42
  style row(0..1).column(7), :size => 10 , :align => :center , :width => 49
  style row(0..1).column(8), :size => 10 , :align => :center , :width => 54
  style row(0..1).column(9), :size => 10 , :align => :center , :width => 55
  style row(0..1).column(10), :size => 10 , :align => :center , :width => 54
  style row(0..1).column(11), :size => 10 , :align => :center , :width => 21
  style row(0..50000).column(1..10), :size => 9 , :align => :right 
  style row(0..50000).column(1), :size => 9 , :align => :center 
  style row(0..1).column(0..10),:align=>:center
style row(0..20).column(0),:border_width=>0
style row(0..20).column(11),:border_width=>0
style row(2..50000).column(0..11), :size => 9

  # style row(1).column(0), :size => 11 , :align => :center , :width => 70, :font_style => :bold
  # style row(1).column(1), :size => 11 , :align => :center , :width => 70, :font_style => :bold
  # style row(1).column(2), :size => 11 , :align => :center , :width => 80, :font_style => :bold
  # style row(1).column(3), :size => 11 , :align => :center , :width => 70, :font_style => :bold
  # style row(1).column(4), :size => 11 , :align => :center , :width => 80, :font_style => :bold
  # style row(1).column(5), :size => 11 , :align => :center , :width => 70, :font_style => :bold
  # style row(1).column(6), :size => 11 , :align => :center , :width => 82, :font_style => :bold


  

end
move_down 10

data28 = ([
  [{:content => "#{Prawn::Text::NBSP*10}This certificate is issued at the request of "+@seawdarsobj.sw_sewadar_prefix.to_s+". "+(@seawdarsobj ? @seawdarsobj.sw_sewadar_name.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ") : '' ).to_s+", Sewadar for the purpose of securing loan from Bank ."},
    {:content =>""},
    {:content => ""}]
])
table([] + data28, :width => 558) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end
move_down 25




data27 = ([
  [{:content => ""},
   {:content => ""},
   {:content => "("+hodnames.to_s+") \n Member Incharge \n "+departmentname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")}]
])
table([] + data27, :width => 550) do
  style row(0), :border_width => 0 , :size => 11 , :align => :center, :font_style => :bold
  style column(0..1), :width => 160
end


  move_down 100
  if ps.to_i%2 == 0
     move_down 60
  end
  ps +=1
  
  
    # end ## end    for
   #end  ## if

    
   
   
  end
  

 private
   def format_oblig_date(dates)
        newdate = ''
        if dates!=nil && dates!=''
             dts    = Date.parse(dates.to_s)
             newdate = dts.strftime("%d/%m/%Y")
        end
        return newdate
   end

private
def number_currency_in_words
   to_words(@tnetamt.to_f)  
 end

private
   def currency_formatted(amt)
        amts = ''
        if amt!=nil && amt!=''
          amts = "%.2f" % amt.to_f
        end
        return amts
   end

private
 def formatted_date(dates)
      newdate = ''
      if dates!=nil && dates!=''
           dts    = Date.parse(dates.to_s)
           newdate = dts.strftime("%d/%b/%Y")
      end
      return newdate
 end

def count
  @count ||= 0
  @count = @count+1
end
def make_sum_of_all
    @tqnty    = 0
    @tdsamt   = 0
    @tcih     = @invoice.csh_inhandcash
    @tbalance = @invoice.csh_balance
    @tnetamt  = @invoice.csh_depositpmt
    @dtvalues = 0
    @tcgst    = 0
    @tsgst    = 0
    @gstamt   = 0
    @ttax     = 0
    @subtotal = 0
 
   
   
 end

def to_words(num)
  numbers_to_name = {
      10000000 => "Crore",
      100000 => "Lakh",
      1000 => "Thousand",
      100 => "Hundred",
      90 => "Ninety",
      80 => "Eighty",
      70 => "Seventy",
      60 => "Sixty",
      50 => "Fifty",
      40 => "Forty",
      30 => "Thirty",
      20 => "Twenty",
      19=>"Nineteen",
      18=>"Eighteen",
      17=>"Seventeen",
      16=>"Sixteen",
      15=>"Fifteen",
      14=>"Fourteen",
      13=>"Thirteen",
      12=>"Twelve",
      11 => "Eleven",
      10 => "Ten",
      9 => "Nine",
      8 => "Eight",
      7 => "Seven",
      6 => "Six",
      5 => "Five",
      4 => "Four",
      3 => "Three",
      2 => "Two",
      1 => "One"
    }

  log_floors_to_ten_powers = {
    0 => 1,
    1 => 10,
    2 => 100,
    3 => 1000,
    4 => 1000,
    5 => 100000,
    6 => 100000,
    7 => 10000000
  }

  num = num.to_i
  return '' if num <= 0 or num >= 100000000

  log_floor = Math.log(num, 10).floor
  ten_power = log_floors_to_ten_powers[log_floor]

  if num <= 20
    numbers_to_name[num]
  elsif log_floor == 1
    rem = num % 10
    [ numbers_to_name[num - rem], to_words(rem) ].join(' ')
  else
    [ to_words(num / ten_power), numbers_to_name[ten_power], to_words(num % ten_power) ].join(' ')
  end
end
end