# To change this template, choose Tools | Templates
# and open the template in the editor.

class ExgratiasanctionPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,reqsess,uRl,hods,hodhumane)
    super(:top_margin=>5,:page_size =>"A4",:background =>  "public/assets/img/HRD1.png" )  
    @seawdarsobj          = seawdarsobj
    @compDetail           = compdetail   
    @uRl2                 = uRl
    @hods                 = hods
    @uRl                  = Rails.root.join "public"
    @logoSize             = 0.5 
    @hodhumane            = hodhumane  
    line_items
    
 end


 
 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
     ps = 1
       
   move_down 150

    departmentname = @seawdarsobj ? @seawdarsobj[0].department : ''
    designation    = @seawdarsobj ? @seawdarsobj[0].designation : ''
    dtyears        = Date.today.strftime("%Y")
    ddated         = Date.today.strftime("%d-%b-%Y")
    orgnization    = @compDetail ? @compDetail.cmp_companyname : ''
    pincode        = @compDetail ? @compDetail.cmp_addressline3 : ''
    address1       = @compDetail ? @compDetail.cmp_typeofbussiness : ''
    address2       = @compDetail ? @compDetail.cmp_addressline2 : ''
    hodnamed       = @hods ? @hods.lds_name : ''
#   data21 = ([

#     [{:content => ""},
#     {:content => " "},
#     {:content => ""}]

#   ])

# table([] + data21, :width => 522) do
#   style row(0), :border_width => 0 , :size => 10 , :align => :center
# end

move_down 30
data22 = ([
  [{:content => "SNM/HRD/"+@seawdarsobj[0].sw_sewcode.to_s+"/"+dtyears.to_s+"/"+@seawdarsobj[0].sanctionno.to_s},
   {:content => ""},
   {:content => "Date : "+ddated.to_s}]

])

table([] + data22, :width => 528)do
style row(0),  :border_width => 0
style column(0), :width     => 340, :align=>:left, :size => 10,:font_style=>:bold
style column(1), :width => 60
style column(2), :width     => 128, :size => 10,:font_style=>:bold
end
data22 = ([
  [{:content => "Rev. "+(hodnamed ? hodnamed.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ") : '' ).to_s+" Ji,\n Member Incharge, Finance & Accounts"+"\n"+address1.to_s+","+"\n"+address2.to_s+","+" \n"+pincode.to_s}],
   [{:content => ""}],
])

table([] + data22, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10

end
sewaprefix   = @seawdarsobj ? @seawdarsobj[0].sewaprefix : ''
data22 = ([
  [{:content => "Subject:<u> Grant of advance Ex-gratia to "+sewaprefix.to_s+". "+(@seawdarsobj ? @seawdarsobj[0].sewdarname.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ") : '' ).to_s+", "+departmentname.to_s.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+" Department</u> "}],
   [{:content => ""}],
])

table([] + data22, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10,:inline_format=>:true,:font_style=>:bold

end
data22 = ([
  [{:content => "Dhan Nirankar Ji, "}],
   [{:content => ""}],
])

table([] + data22, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10

end
move_down 5
data23 = ([
  [{:content=> ""},{:content => "Approval of Human Resources Department, is hereby, accorded for the grant of advance of Exgratia  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10
style row(0).column(0),:width=>53
style row(0).column(1),:width=>470
end
amounts    = @seawdarsobj ? @seawdarsobj[0].totalamount : 0
sewdarname = @seawdarsobj ? @seawdarsobj[0].sewdarname : ''
resons     = @seawdarsobj ? @seawdarsobj[0].al_purpose : ''
mygenders  = @seawdarsobj ? @seawdarsobj[0].genders : ''
@tnetamt   = amounts
gendertitles = ""
 if mygenders && mygenders.to_s.upcase =='F'
  gendertitles = "her"
 else
  gendertitles = "his"
 end

move_up 20
data23 = ([
  [{:content => " payment amounting to <b>Rs. "+currency_formatted(amounts).to_s+"/</b>, (Rupees "+number_currency_in_words+" Only) to "+sewaprefix.to_s+". "+sewdarname.to_s.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+", Sewadar, "+departmentname.to_s.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+"  Department in connection with "+resons.to_s+".  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10,:inline_format=>:true

end
data23 = ([
  [{:content=> "2."},{:content => "The advance of ex-gratia payment would be deducted from "+gendertitles.to_s+" Sewa Nivriti Aashirwad at the time of relinquishing from sewa on attaining the age of sewa nivriti or otherwise.  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10
style row(0).column(0),:width=>53
style row(0).column(1),:width=>470
end
data23 = ([
  [{:content=> "3."},{:content => "The Account Payee Cheque in the name of <b>"+sewaprefix.to_s+". "++sewdarname.to_s.to_s.split(/ |\_|\-/).map(&:capitalize).join(" ")+"</b> may please be prepared and sent to Human Resource Department to tender the same to the concerned Sewadar.  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10,:inline_format=>:true
style row(0).column(0),:width=>53
style row(0).column(1),:width=>470
end
data23 = ([
  [{:content=> "4."},{:content => "The expenditure involved may be debitable to the head “Welfare to Sewadar (Ex-gratia/ Retirement Benefits)”  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10
style row(0).column(0),:width=>53
style row(0).column(1),:width=>470
end
move_down 10
data23 = ([
  [{:content=> ""},{:content => "With regards,  "}],
   [{:content => ""}],
])

table([] + data23, :width => 523)do
style row(0..100),  :border_width => 0,:align=>:left,:size=> 10
style row(0).column(0),:width=>53
style row(0).column(1),:width=>470
end



move_down 20
data26 = ([
  [{:content => ""},
   {:content => ""},
   {:content => "Humbly yours, "}]
])
table([] + data26, :width => 528) do
  style row(0), :border_width => 0 , :size => 10 , :align => :center,:inline_format=>:true
  style row(0)
  style column(0..1), :width => 160
end
hodnames =  @hodhumane #@seawdarsobj ? @seawdarsobj[0].approvedby : ''
move_down 15
data27 = ([
  [{:content => ""},
   {:content => ""},
   {:content => "<b>("+hodnames.to_s+")</b> \n Member Incharge \n "+"Human Resource Department"}]
])
table([] + data27, :width => 528) do
  style row(0), :border_width => 0 , :size => 10 , :align => :center,:inline_format=>:true
  style row(0)
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