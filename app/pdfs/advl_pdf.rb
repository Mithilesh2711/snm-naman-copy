# To change this template, choose Tools | Templates
# and open the template in the editor.

class AdvlPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,uRl,sewadarpersonal,empchecked,empkyc,empkycbank,empqualif,familydetail,empworkexp,empstatelist,empdistrict,hodlisted,empdepartment)
    super(:top_margin=>5,:page_size =>"A4",:background => "public/assets/img/HRD1.png" )
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
  #      #if @salary && @salary.length >0
  #        #@salary.each do |newsalry|
  #        move_down 30
  #       image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
  #       data1 = ([
  #          [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>", :inline_format=> true , :size => 15}, 
  #           {:content =>" "}, 
  #           {:content => "<b>""DR. PARVEEN KHULLAR""</b>"+"\nMember Incharge""\n"+"Contact No : 9266629833 \n9999999999""\n"+"Email: hrd@nirankari.org"+"\n""Web: www.nirankari.org", :inline_format=> true , :size => 10} ],
  #       ])


  # table([] + data1,:width =>528)  do
  #   style row(0),  :border_width => 0
  #   style column(0), :width     => 60, :align=>:left, :text_color => "346842"
  #   style column(1), :width => 100
  #   style column(2), :width     => 220, :size => 9,  :text_color => "346842"
  #   #cells.padding = 3
  #   #style row(2),  :size => 12,:align=>:center, :border_width => 0
  #   #style row(0..6).column(0), :width     => 528
  #   #row(2).font_style = :bold
  #   #self.row_colors =["FFFFFF"]
  #   #self.header =true
  #   #row(0).column(0).background_color = 'DCDCDC'
  # end

  move_down 150

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
# data21 = ([

#   [{:content => ""},
#   {:content => departmentname.to_s.upcase},
#   {:content => ""}]

# ])

# table([] + data21, :width => 522) do
# style row(0), :border_width => 0 , :size => 10 , :align => :center
# style row(0).column(1), :background_color => "D3D3D3"
# end

move_down 30
data22 = ([
  [{:content => "SNM/HRD/"+@seawdarsobj.sw_sewcode.to_s+"/"+dtyears.to_s+"/""______"},
   {:content => ""},
   {:content => "Date : "+ddated.to_s}]

])

table([] + data22, :width => 528)do
style row(0),  :border_width => 0
style column(0), :width     => 200, :align=>:left, :size => 12
style column(1), :width => 200
style column(2), :width     => 128, :size => 12
end

move_down 30
data23 =([
  [{:content => ""},
   {:content =>"TO WHOM IT MAY CONCERN"},
   {:content => ""}]
])

table([] + data23, :width => 528) do
  style row(0), :border_width => 0 , :size => 12 , :align => :center
  style row(0).column(1), :font_style => :bold, :border_bottom_width => 1 , :width => 180
end




typeofx = ""
namex   = ""
if @seawdarsobj
 if @seawdarsobj.sw_gender == 'F'
     if @seawdarsobj.sw_maritalstatus == 'Y'
       typeofx = "W/O"
       namex   = @seawdarsobj.sw_husbprefix.to_s+" "+@seawdarsobj.sw_husbandname.to_s
     else
       typeofx = "D/O"
       namex   = @seawdarsobj.sw_father_prefix.to_s+" "+@seawdarsobj.sw_father_name
     end
 else
    typeofx = "S/O"
    namex   = @seawdarsobj.sw_father_prefix.to_s+" "+@seawdarsobj.sw_father_name
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


typeofme2 = ""
if @seawdarsobj
  if @seawdarsobj.sw_gender == 'F'
     typeofme2 = "She"
  else
     typeome2 = "He"

  end
 
 end
 if @seawdarsobj
  if @seawdarsobj.sw_gender == 'F'
      if @seawdarsobj.sw_maritalstatus == 'Y'
        typeofx2 = "Mrs."
      
      else
        typeofx2 = "Ms."
        
      end
  else
     typeofx2 = "Mr."
     
  end
 
 end


move_down 30
data24 = ([
  [{:content => "#{Prawn::Text::NBSP*10}This is to certify that "+typeofx2.to_s+" "+(@seawdarsobj ? @seawdarsobj.sw_sewadar_name : '' ).to_s+" "+typeofx.to_s+" "+namex.to_s+" is doing sewa at"" "+@compDetail.cmp_companyname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+", " +@compDetail.cmp_addressline1.to_s.to_s+"."+typeofme2.to_s+" is being paid a total maintenance of Rs 36,713/- (Rupees thirty six thousand seven hundred and thirteen only) per month w.e.f 1 April 2021."},
    {:content => ""},
    {:content => ""}]
])
table([] + data24, :width => 528) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end



# data25 = ([
#   [{:content =>""},
#    {:content => "Sant Nirankari Mandal has no objection for his visit to Canada. "},
#    {:content => ""}]
# ])
# table([] + data25, :width => 528) do
#   style row(0), :border_width => 0 , :size => 11 , :align => :center
# end


# data26 = ([
#   [{:content => ""},
#     {:content =>"He has also been provided with residential accommodation by the Sant Nirankari Mandal"},
#     {:content => ""}]
# ])
# table([] + data26, :width => 528) do
#   style row(0), :border_width => 0 , :size => 11 , :align => :center
# end



typeofme = ""
if @seawdarsobj
  if @seawdarsobj.sw_gender == 'F'
     typeofme = "her"
  else
     typeome = "his"

  end
 
 end

 
data28 = ([
  [{:content => ""},
    {:content =>"This certificate is issued at the request of "+typeofx2.to_s+" "+(@seawdarsobj ? @seawdarsobj.sw_sewadar_name : '' ).to_s+" as the same is required for education of "+typeofme.to_s+" daughter."},
    {:content => ""}]
])
table([] + data28, :width => 528) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end
move_down 70





data27 = ([
  [{:content => ""},
   {:content => ""},
   {:content => "("+hodnames.to_s+") \n Member Incharge \n "+departmentname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")}]
])
table([] + data27, :width => 528) do
  style row(0), :border_width => 0 , :size => 11 , :align => :center, :font_style => :bold
  style column(0..1), :width => 160
end





#   data2 = ([
#       [{:content =>"Emp Name"}, {:content =>":"}, {:content =>''}, {:content =>"Department"}, {:content =>":"}, {:content =>''}, {:content =>"Bank Name"}, {:content =>":"}, {:content =>''}],
#       [{:content =>"F/H Name"}, {:content =>":"}, {:content =>''}, {:content =>"Designation"}, {:content =>":"}, {:content =>''}, {:content =>"Acc No."}, {:content =>":"}, {:content =>''}],
#       [{:content =>"Emp Code"}, {:content =>":"}, {:content =>''}, {:content =>"Joining Date"}, {:content =>":"}, {:content =>''}, {:content =>"IFSC Code"}, {:content =>":"}, {:content =>''}],
#       [{:content =>"Ref. Code"}, {:content =>":"}, {:content =>''}, {:content =>""}, {:content =>""}, {:content =>""}, {:content =>"State"}, {:content =>":"}, {:content =>''}],
#   ])
# table([] + data2,:cell_style => {:inline_format => true })  do
#     style row(0..3),  :size => 8, :align=>:left
#     style row(0..3).column(0), :width =>60
#     style row(0..3).column(1), :width =>10
#     style row(0..3).column(2), :width =>91
#     style row(0..3).column(3), :width =>70
#     style row(0..3).column(4), :width =>10
#     style row(0..3).column(5), :width =>96
#     style row(0..3).column(6), :width =>70
#     style row(0..3).column(7), :width =>20
#     style row(0..3).column(8), :width =>96
#     style row(0..3), :border_width => 0
#     style column(0), :border_left_width => 1
#     style column(2), :border_right_width => 1
#     style column(5), :border_right_width => 1
#     style column(8), :border_right_width => 1
#     style row(0), :border_top_width => 1
#     style row(3), :border_bottom_width => 1
    #row(0..1).column(0).font_style = :bold
    #cells.size = 9
  #   cells.padding = 3
  # end


#   move_down 2
#   netpayable = newsalry.pm_arear.to_f+newsalry.pm_basic.to_f
# data3 = ([
#   [{:content =>"Days",:inline_format=>:true,:colspan=>2}, {:content =>"Allowance Details", :inline_format=>:true,:colspan=>2}, {:content =>"Deductions",:inline_format=>:true,:colspan=>2}, {:content =>"Net Amount"}],
#   [{:content =>"WD"}, {:content =>newsalry.pm_workingday.to_s}, {:content =>"Gross MA"}, {:content =>currency_formatted(newsalry.pm_actbasic).to_s}, {:content =>"LIC"}, {:content =>currency_formatted(newsalry.pm_ded_licemployee).to_s}, {:content =>"Total Days"}],
#   [{:content =>"PL"}, {:content =>newsalry.pm_paidleave.to_s}, {:content =>"<b>Payable</b>",:inline_format=>:true,:colspan=>2,:border_bottom_width=>1}, {:content =>"Building"}, {:content =>currency_formatted(newsalry.pm_dedaccomodatamount).to_s}, {:content =>newsalry.pm_paydays.to_s}],
#   [{:content =>"HL"}, {:content =>newsalry.pm_hl.to_s}, {:content =>"Arrear"}, {:content =>""}, {:content =>"Electricity"}, {:content =>currency_formatted(newsalry.pm_ded_electricamount).to_s}, {:content =>"Net Amount"}],
#   [{:content =>"WO"}, {:content =>newsalry.pm_wo.to_s}, {:content =>"MA"}, {:content =>currency_formatted(newsalry.pm_basic).to_s}, {:content =>"Repaid"}, {:content =>currency_formatted(newsalry.pm_ded_repaidadvance).to_s}, {:content =>currency_formatted(newsalry.pm_netpay).to_s}],
#   [{:content =>"ABS"}, {:content =>newsalry.pm_absent.to_s}, {:content =>""}, {:content =>""}, {:content =>"Health"}, {:content =>currency_formatted(newsalry.pm_ded_healthsewdarpay).to_s}, {:content =>"Total Deductions"}],
#   [{:content =>""}, {:content =>""}, {:content =>""}, {:content =>""}, {:content =>"Income Tax"}, {:content =>currency_formatted(newsalry.pm_incometaxamount).to_s}, {:content =>currency_formatted(newsalry.pm_totaldeduction).to_s+'Net Payable : '+currency_formatted(netpayable).to_s}],
#   ])
# table([] + data3,:width =>528)  do
# style row(0),  :size => 8, :align=>:left
# style row(1..6).column(0..6),  :size => 8, :align=>:left, :border_bottom_width=>0,:border_top_width=>0
# row(0).background_color = '48D1CC'
# style column(0), :border_right_width=>0,:width=>75
# style column(1), :border_left_width=>0,:align=>:right,:width=>75
# style column(2), :border_right_width=>0,:width=>75
# style column(3), :border_left_width=>0,:align=>:right,:width=>75
# style column(4), :border_right_width=>0,:width=>75
# style column(5), :border_left_width=>0,:align=>:right,:width=>75
# style column(6),:width=>78,:align=>:center
# style row(2).column(2..3), :align=>:center, :style=>:bold
# style row(1..6).column(6),  :size => 8, :align=>:center
# style row(2).column(6), :border_bottom_width=>1
# style row(4).column(6), :border_bottom_width=>1
# row(0).font_style = :bold
# style row(0), :align=>:center
# cells.padding = 5
# end

# data4 = ([
#   [{:content =>"*This document is computer generated and does not require the signature",:inline_format=>:true,:colspan=>9}]
# ])
# table([] + data4,:width=>528) do
#   style row(0),  :size => 8, :align=>:center
# end
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
          amts = amt.to_f.round(0)
        end
        return amts
   end

private
 def formatted_date(dates)
      newdate = ''
      if dates!=nil && dates!=''
           dts    = Date.parse(dates.to_s)
           newdate = dts.strftime("%d-%b-%Y")
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