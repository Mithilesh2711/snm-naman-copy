# To change this template, choose Tools | Templates
# and open the template in the editor.

class ElecPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,uRl,sewadarpersonal,empchecked,empkyc,empkycbank,empqualif,familydetail,empworkexp,empstatelist,empdistrict,hodlisted,empdepartment)
    super(:left_margin=>35,:right_margin=>40,:top_margin=>5,:page_size =>"A4",:background => "public/assets/img/HRD1.png" )
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
  [{:content => ""},
   {:content => "Ref: SNM/HRD/"+@seawdarsobj[0].sw_sewcode.to_s+"/"+dtyears.to_s+"/""______"},
   {:content => "Date : "+ddated.to_s}]

])

table([] + data22, :width => 528)do
style row(0),  :border_width => 0
style column(0), :width     => 15, :align=>:left, :size => 12
style column(1), :width => 385
style column(2), :width     => 128, :size => 12
end
move_down 30
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
 if @seawdarsobj[0].sw_gender == 'F'
     if @seawdarsobj[0].sw_maritalstatus == 'Y'
       typeofx = "W/O"
       namex   = @seawdarsobj[0].sw_husbprefix.to_s+". "+@seawdarsobj[0].sw_husbandname.to_s
     else
       typeofx = "D/O"
       namex   = @seawdarsobj[0].sw_father_prefix.to_s+". "+@seawdarsobj[0].sw_father_name
     end
 else
    typeofx = "S/O"
    namex   = @seawdarsobj[0].sw_father_prefix.to_s+". "+@seawdarsobj[0].sw_father_name
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
# if @sewadarpersonal
   
#  personaladdress = @sewadarpersonal.sp_pres_houseaddress.to_s+(districtname ? ", "+districtname : '').to_s+(statename ? ", "+statename : '').to_s+(@sewadarpersonal.sp_pres_pincode ? ", "+@sewadarpersonal.sp_pres_pincode : '').to_s

# end


typeofme2 = ""
if @seawdarsobj
  if @seawdarsobj[0].sw_gender == 'F'
     typeofme2 = "she"
  else
     typeofme2 = "he"

  end
 
 end
#  typeofx2 = ""
# if @seawdarsobj
#  if @seawdarsobj.sw_gender == 'F'
#      if @seawdarsobj.sw_maritalstatus == 'Y'
#        typeofx2 = "Mrs."
     
#      else
#        typeofx2 = "Ms."
       
#      end
#  else
#     typeofx2 = "Mr."
    
#  end

# end
netmaintenace = @empChecked ? @empChecked.so_totalgross : 0
if netmaintenace.to_f <=0
  netmaintenace = @empChecked ? @empChecked.so_basic : 0
end
@tnetamt =netmaintenace

move_down 30
data24 = ([
  [{:content => ""},
  {:content => "#{Prawn::Text::NBSP*10}This is to certify that "+@seawdarsobj[0].sw_sewadar_prefix.to_s+". "+(@seawdarsobj ? @seawdarsobj[0].sewadarname : '' ).to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" "+typeofx.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" "+namex.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" has been rendering sewa at"" "+@compDetail.cmp_companyname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+", " +@compDetail.cmp_addressline1.to_s.to_s+" since "+formatted_date(@seawdarsobj[0].sw_joiningdate).to_s+". As per our records, "+typeofme2.to_s+" is being paid Rs."+currency_formatted(netmaintenace).to_s+"/- (Rupees "+number_currency_in_words+" Only) per month as Maintenance Allowance. "},
    {:content => ""}]
])
table([] + data24, :width => 528) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end


typeofme = ""
if @seawdarsobj
  if @seawdarsobj[0].sw_gender == 'F'
     typeofme = "her"
  else
     typeofme = "his"

  end
 
 end

 



data25 = ([
  [{:content =>""},
   {:content => "#{Prawn::Text::NBSP*10}Sant Nirankari Mandal has no objection for "+typeofme.to_s+" visit to  ______________. "},
   {:content => ""}]
])
table([] + data25, :width => 528) do
  style row(0), :border_width => 0 , :size => 11 , :align => :justify
end


# data26 = ([
#   [{:content => ""},
#     {:content =>"He has also been provided with residential accommodation by the Sant Nirankari Mandal"},
#     {:content => ""}]
# ])
# table([] + data26, :width => 528) do
#   style row(0), :border_width => 0 , :size => 11 , :align => :center
# end

data28 = ([
  [{:content => ""},
    {:content =>"#{Prawn::Text::NBSP*10}This certificate is issued at the request of "+@seawdarsobj[0].sw_sewadar_prefix.to_s+". "+(@seawdarsobj ? @seawdarsobj[0].sewadarname : '' ).to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" for applying for a tourist VISA"},
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



#
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