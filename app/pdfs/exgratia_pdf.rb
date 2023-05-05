# To change this template, choose Tools | Templates
# and open the template in the editor.

class ExgratiaPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,uRl,sewadarpersonal,empchecked,empkyc,empkycbank,empqualif,familydetail,empworkexp,empstatelist,empdistrict,hodlisted,empdepartment,fullfinal,paymonthlisted,lastdrawns,preparedby)
    super(:top_margin=>35,:page_size =>"A4" )
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
    @fullfinal            = fullfinal
    @paymonthlisted       = paymonthlisted
    @lastdrawns           = lastdrawns
    @preparedby           = preparedby
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
       #if @salary && @salary.length >0
         #@salary.each do |newsalry|
        #  move_down 30
        # image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
        # data1 = ([
        #    [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>", :inline_format=> true , :size => 15}, 
        #     {:content =>" "}, 
        #     {:content => "<b>""DR. PARVEEN KHULLAR""</b>"+"\nMember Incharge""\n"+"Contact No : 9266629833 \n9999999999""\n"+"Email: hrd@nirankari.org"+"\n""Web: www.nirankari.org", :inline_format=> true , :size => 10} ],
        # ])


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
  
  data21 = ([

    [
    {:content => "SANT NIRANKARI MANDAL (REGD.)"}],
    [ {:content => "(HUMAN RESOURCES DEPARTMENT)"}]

  ])

table([] + data21, :width => 522) do
  style row(0..100), :border_width => 0 , :size => 12 , :align => :center
  style row(0).column(0), :font_style => :bold,:size=>20
end

   move_down 0
   data2 = ([

    [{:content => ""},
    {:content => ""},
    {:content => "Dated : "+formatted_date(Date.today).to_s}]

  ])

table([] + data2, :width => 522) do
  style row(0), :border_width => 0 , :size => 12 , :align => :center
  style row(0).column(1), :font_style => :bold, :width => 350
end

   
  data21 = ([

    [{:content => ""},
    {:content => "<u>Calculation of Ex-gratia payment of Sewadar</u>"},
    {:content => ""}]

  ])

table([] + data21, :width => 522) do
  style row(0), :border_width => 0 , :size => 10 , :align => :center,:inline_format=>:true
  style row(0).column(1), :font_style => :bold
end
spldays     = ""
monthdated  = ""
yearsdated  = ""

if @fullfinal
  if @fullfinal.ff_totalsewa.to_s !=nil && @fullfinal.ff_totalsewa.to_s !=''
    spldays = @fullfinal.ff_totalsewa.to_s.split("and")
  end
    stpobj       = formatted_date(@fullfinal.ff_leavingdate)
    stpobjx      = stpobj ? stpobj.split("-") : ''
    monthdated   = stpobjx ? stpobjx[1] : ''
    yearsdated   = stpobjx ? stpobjx[2] : ''
end
yesno = ""
if @fullfinal && @fullfinal.ff_vaccant.to_s=='N'
  yesno = 'No'
elsif @fullfinal && @fullfinal.ff_vaccant.to_s=='Y'  
  yesno = 'Yes'
end
refcode = ""
if @seawdarsobj
    if  @seawdarsobj.sw_oldsewdarcode != nil && @seawdarsobj.sw_oldsewdarcode != ''
        refcode = " ("+@seawdarsobj.sw_oldsewdarcode.to_s+")"
    end
end
excepayment      = @fullfinal.ff_deductfirst.to_f+@fullfinal.ff_deductsecond.to_f+@fullfinal.ff_totaladvance.to_f#+(@paymonthlisted ? @paymonthlisted.pm_ded_licemployee : 0).to_f
totals           = @fullfinal.ff_gratiaamount.to_f+@fullfinal.ff_encashel.to_f+(@paymonthlisted ? @paymonthlisted.pm_netpay : 0).to_f
nettotals        = totals.to_f-excepayment.to_f-@fullfinal.ff_exgratiatued.to_f
nettotals        = nettotals.to_f >0 ? nettotals.to_f.round(0) : ''
if nettotals.to_f >1500000
   nettotals = 1500000
end
newfullfinalamt  = @fullfinal ? currencyformatted(@fullfinal.ff_encashel).to_f.round(0) : ''
lessadvance      = @fullfinal ? currencyformatted(@fullfinal.ff_totaladvance).to_f.round(0) : ''
 
data22 = ([
  [{:content=>"1.  "+ "Name of Sewadar with Code No.  : " +"<b>"+ ( @seawdarsobj ? @seawdarsobj.sw_sewadar_name.to_s+" ,"+@seawdarsobj.sw_sewcode.to_s : '').to_s+refcode.to_s+"</b>"  }], 
  [{:content => "2.  "+"Date of Birth  : "+"<b>"+ (  @fullfinal ? formatted_date(@fullfinal.ff_dob).to_s : '').to_s+"</b>" }],
  [{:content => " 3.  "+"Department to which Attached  : " + "<b>"+( @EmpDepartment ? @EmpDepartment.departDescription : '').to_s+"</b>" }],
  [{:content => " 4.  "+"Date of Appointment  : "+ "<b>"+( @fullfinal ? formatted_date(@fullfinal.ff_datejoing).to_s : '').to_s+"</b>" }],
  [{:content => "5.  "+"Date of Leaving/Resignation/termination/death  : "+"<b>"+( @fullfinal ? formatted_date(@fullfinal.ff_leavingdate).to_s : '').to_s+"</b>" }],
  [{:content=>"6.  "+"Total Sewa  : "+ "<b>"+(@fullfinal.ff_beforelwmtotalsewa.to_s).to_s+"</b>"}],
  [{:content=>"6.a  "+"Less leave without maintenance days  : "+ "<b>"+(@fullfinal.ff_totallwm.to_s).to_s+"</b>"}],
  [{:content=>"6.b  "+"Total sewa after leave without maintenance  : "+ "<b>"+(@fullfinal.ff_totalsewa.to_s).to_s+"</b>"}],
  
  [{:content => "7. "+"Maintenance Allowance & other Allowances Last Drawn  : "+"<b>Rs."+(@fullfinal ?currencyformatted(@fullfinal.ff_maintenancealw).to_s : '').to_s+"</b>"}],
  [{:content => " 8. "+"Lump Sum Exgratia\n#{Prawn::Text::NBSP*4}(Monthly Maintenance Allowance X No. of Years) :  "+"Rs."+"<b>"+(@fullfinal ? currencyformatted(@fullfinal.ff_gratiaamount).to_s : '').to_s+"</b>" }],
  [{:content => "9. "+"Total Earned Leave credit as on  "+"<b>"+monthdated.to_s+" , "+yearsdated.to_s+" : "+""+(@fullfinal ? @fullfinal.ff_totalel.to_s : '').to_s+"</b>"}],
  [{:content => "10. "+ "Encashment of Earned Leave  \n#{Prawn::Text::NBSP*5}(Monthly Maintenance Allowance X No. of Days)/30 :  "+"Rs."+"<b>"+(newfullfinalamt).to_s+"</b>"}],
  [{:content => "11. "+ "Maintenance Allowance for the current period i.e upto  : "+ "Rs."+"<b>"+(@paymonthlisted ? currencyformatted(@paymonthlisted.pm_netpay).to_s : '').to_s+"</b>"}],
  [{:content => "12. "+ "Less outstanding advance  : "+"Rs. "+"<b>"+(lessadvance).to_s+"</b>"}],
 # [{:content => "13. "+"LIC Premium  : "+"Rs. "+"<b>"+(@paymonthlisted ? currencyformatted(@paymonthlisted.pm_ded_licemployee).to_s : '').to_s+"</b>"}],
  [{:content => " 13. "+ "Deductions : "+(@fullfinal.ff_deductfirstrmk.to_s !='' ? " : " : '0.00' ).to_s+"#{Prawn::Text::NBSP*6}"+(@fullfinal && @fullfinal.ff_deductfirstrmk.to_s!='' ? @fullfinal.ff_deductfirstrmk.to_s+" : " : '').to_s+(@fullfinal.ff_deductfirst.to_f >0 ? "<b>Rs. "+currencyformatted(@fullfinal.ff_deductfirst).to_s+" </b>" : '').to_s+( @fullfinal.ff_deductsecond.to_f >0 ? (@fullfinal ? ", "+@fullfinal.ff_deductsecrmk.to_s+" : " : '').to_s+"<b>Rs. "+currencyformatted(@fullfinal.ff_deductsecond).to_s+"</b>" : '').to_s}],
  [{:content => "14. "+"Advance Exgratia : "+"Rs."+"<b>"+@fullfinal.ff_exgratiatued.to_s+"</b>"}],
  [{:content => "15. "+"Net Payment  : "+"Rs."+"<b>"+nettotals.to_s+"</b>"}],
  [{:content => " 16. "+"Whether Sewadar is occupying Mandal Accomodation\n#{Prawn::Text::NBSP*6}(If so, please ensure vacation of accomodation before Making payment)  "+"<b>"+(yesno.to_s).to_s+"</b>"}],
  
    

])

table([] + data22, :width => 523)do
style row(0..100),  :border_width => 0,:size=>10,:inline_format=>:true
# style row(0..4).column(0), :width     => 28, :align=>:left, :size => 10
# style row(0..4).column(1), :width => 500, :size => 10
# style row(0..4).column(2), :width     => 133, :size => 10
# style row(5).column(0), :width => 50, :align=>:left, :size => 12
# style row(5).column(1), :width => 277, :align=>:left, :size => 12
# style row(5).column(2), :width => 67, :align=>:left, :size => 12
# style row(5).column(3), :width => 67, :align=>:left, :size => 12
# style row(5).column(4), :width => 67, :align=>:left, :size => 12

end


# data221 = ([
#   [{:content=>"6."}, {:content => "Total Sewa"}, {:content => ""},{:content => "#{Prawn::Text::NBSP*10}"+@fullfinal.ff_totalsewa.to_s}],
#   [{:content=>""},  "",""],
 

# ])

#   table([] + data221, :width => 528)do
#   style row(0..100),  :border_width => 0
#   style row(0..4).column(0), :width     => 25, :align=>:left, :size => 10
#   style row(0..4).column(1), :width => 330, :size => 10
#   style row(0..4).column(2), :width => 40, :size => 10
#   style row(0..4).column(3), :width => 133, :size => 10,:align=>:left
  
  
#   end
 
 
    # data223 = ([
    #   [{:content => "7. "},
    #    {:content => "Maintenance Allowance & other Allowances Last Drawn"},
    #    {:content => ""+(@lastdrawns ? currencyformatted(@lastdrawns.pm_basic).to_s : '').to_s}],
    #   [{:content => " 8."},
    #    {:content => "Lump Sum Exgratia\n(Monthly Maintenance Allowance X No. of Years) = "},
    #    {:content => "Rs."+(@fullfinal ? currencyformatted(@fullfinal.ff_gratiaamount).to_s : '').to_s}],
    #   [{:content => "9. "},
    #    {:content => "Total Earned Leave credit as on "+monthdated.to_s+" , "+yearsdated.to_s+" = "},
    #    {:content => ""+(@fullfinal ? @fullfinal.ff_totalel.to_s : '').to_s}],
    #   [{:content => "10. "},
    #    {:content => "Encashment of Earned Leave\n(Monthly Maintenance Allowance X No. of Days)/30"},
    #    {:content => "Rs."+(@fullfinal ? currencyformatted(@fullfinal.ff_encashel).to_s : '').to_s}],
    #   [{:content => "11. "},
    #    {:content => "Maintenance Allowance for the current period i.e upto"},
    #    {:content => ""+(@fullfinal ?currencyformatted(@fullfinal.ff_maintenancealw).to_s : '').to_s}],
    #   # [{:content => " "},
    #   #  {:content => "Total of Sr. No 8,10 & 11 ="},
    #   #  {:content => "Rs...... "}],
    #   [{:content => "12. "},
    #    {:content => "Less outstanding advance"},
    #    {:content => "Rs."+(@fullfinal ? currencyformatted(@fullfinal.ff_totaladvance).to_s : '').to_s}],
    #   [{:content => "13. "},
    #    {:content => "LIC Premium"},
    #    {:content => "Rs. "+(@paymonthlisted ? currencyformatted(@paymonthlisted.pm_ded_licemployee).to_s : '').to_s}],
    #   [{:content => " 14."},
    #    {:content => "Excess Payment"},
    #    {:content => "Rs. 0"}],
    #   [{:content => "15. "},
    #    {:content => "Net Payment"},
    #    {:content => "Rs."+(@paymonthlisted ? currencyformatted(@paymonthlisted.pm_netpay).to_s : '').to_s}],
    #   [{:content => " 16."},
    #    {:content => "Whether Sewadar is occupying Mandal Accomodation\n(If so, please ensure vacation of accomodation before Making payment)"},
    #    {:content => yesno.to_s}],
    # ])
    
    # table([] + data223, :width => 528)do
    # style row(0..10),  :border_width => 0,:size=>10
    # style row(0..4).column(0), :width     => 25, :align=>:left, :size => 10
    # style row(0..4).column(1), :width => 370, :size => 10
    # style row(0..4).column(2), :width     => 133, :size => 10
    # # style row(5).column(0), :width => 50, :align=>:left, :size => 12
    # # style row(5).column(1), :width => 277, :align=>:left, :size => 12
    # # style row(5).column(2), :width => 67, :align=>:left, :size => 12
    # # style row(5).column(3), :width => 67, :align=>:left, :size => 12
    # # style row(5).column(4), :width => 67, :align=>:left, :size => 12
    
    # end   
    move_down 100

    data224 = ([
      [{:content => "#{Prawn::Text::NBSP*15}Prepared by"},
       {:content => "(Verified By)"},
       {:content => "(APPROVED) "},{:content=>""}],
      
    
    ])
    
    table([] + data224, :width => 528)do
    style row(0..5),  :border_width => 0, :font_style => :bold
    style row(0..4).column(0), :width     =>176 , :align=>:left, :size => 12
    style row(0..4).column(1), :width     => 151, :align=>:center, :size => 12
    style row(0..4).column(2), :width => 176, :size => 12,:align=>:center
    style row(0..4).column(3), :width     => 25, :size => 12,:align=>:right

    
    
    end
move_down 10
    data225 = ([
      
      [{:content=>""},{:content => @preparedby.to_s},
       {:content => "Manager, HRD"},
       {:content => "Member Incharge\nHuman Resources Department "},{:content=>""}],
    
    ])
    
    table([] + data225, :width => 528)do
    style row(0..5),  :border_width => 0, :font_style => :bold
    style row(0..4).column(0), :width     => 25, :align=>:center
    style row(0..4).column(1), :width     => 151, :align=>:center, :size => 12
    style row(0..4).column(2), :width => 156, :size => 12,:align=>:center
    style row(0..4).column(3), :width     => 176, :size => 12,:align=>:center
    style row(0..4).column(4), :width     => 20, :size => 12
    # style row(5).column(0), :width => 50, :align=>:left, :size => 12
    # style row(5).column(1), :width => 277, :align=>:left, :size => 12
    # style row(5).column(2), :width => 67, :align=>:left, :size => 12
    # style row(5).column(3), :width => 67, :align=>:left, :size => 12
    # style row(5).column(4), :width => 67, :align=>:left, :size => 12
    
    end
move_down 50

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
 def currencyformatted(amt)
      amts = ''
      if amt!=nil && amt!=''
        amts = "%.2f" % amt.to_f
      end
      return amts
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