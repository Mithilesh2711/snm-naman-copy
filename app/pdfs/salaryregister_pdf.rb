# To change this template, choose Tools | Templates
# and open the template in the editor.

class SalaryregisterPdf < Prawn::Document
  def initialize(salary,compdetail,heads,uRl,inchrch)
    super(:top_margin=>30,:bottom_margin=>30,:page_size => "A4",:page_layout => :landscape )
    #:margin_top=>30,:bottom_margin=>30
    @salary     = salary
    @compDetail = compdetail
    @heads      = heads
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5   
    line_items
    
 end

 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
     
        image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
        data1 = ([
           [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\n"+@compDetail.cmp_typeofbussiness.to_s+",\n"+@compDetail.cmp_addressline2.to_s+",\n"+@compDetail.cmp_addressline3.to_s, :inline_format=> true , :size => 10}],
        ])


  table([] + data1,:width =>720)  do
    style row(0).column(0..1), :align=>:left, :border_width => 0
    style column(0), :width     => 60
    style column(2), :width     => 150
    style row(0).column(2), :align=>:right, :border_width => 0
  end
  move_down 10
  data2 = ([
    [{:content=>"Maintenance Allowance For the month of "+( @salary ? selected_month_listed_data(@salary[0].pm_paymonth).to_s : '').to_s+", "+@salary[0].pm_payyear.to_s},{:content=>"Print Date : "+format_oblig_date(Date.today).to_s}]
    ])
    table([] + data2,:width =>760)  do
      style column(0), :width =>390,:border_width=> 0
      style column(1), :width =>370,:border_width=> 0,:align=>:right,:size=>9
    end
 
    data4 = []
    mycount = 1
    tworkingday = 0
    tpaidleave  = 0
    thalfleave  = 0
    tweeklyoff  = 0
    tabsent     = 0
    tgrossma    = 0
    tarears     = 0
    tmabasic    = 0
    tlicamt     = 0
    tbuldamt    = 0
    telectric   = 0
    trepaid     = 0
    thealth     = 0
    tincomtax   = 0
    tdeduction  = 0
    tnetpay     = 0
    tloans      = 0
    tldeductft  = 0
    tldeductsec = 0
    tlallown1   = 0
    tlallown2   = 0

 data4 = [ [{:content =>"S No.", :inline_format=> true ,:rowspan=>2}, {:content =>"Sewadar Code\nName\nDepartment", :inline_format=> true ,:rowspan=>2},  {:content =>"Days", :inline_format=> true ,:colspan=>2},{:content =>"Gross M.A", :inline_format=> true ,:rowspan=>2},{:content => "Payable", :inline_format=>true, :colspan =>2}, {:content =>"Deductions", :inline_format=> true ,:colspan=>2},{:content =>"Total\nDeductions", :inline_format=> true ,:rowspan=>2}, {:content =>"Net M.A.", :inline_format=> true ,:rowspan=>2},{:content =>"Signature", :inline_format=> true ,:rowspan=>2}],
  [ "WD\nPL\nHL\nWO", "ABS\nPD\nMD","Arrear","M.A.\nAllowance 1\nAllowance 2","LIC\nBuilding\nElectricity", "Repaid\nLoan Inst.\nHealth\nIncome Tax\nDeduction 1\nDeduction 2"] ]
  

  if @salary && @salary.length >0
    @salary.each do |newsalry|
     tworkingday += newsalry.pm_workingday.to_f
     tpaidleave  += newsalry.pm_paidleave.to_f
     thalfleave  += newsalry.pm_hl.to_f
     tweeklyoff  += newsalry.pm_wo.to_f
     tabsent     += newsalry.pm_absent.to_f
     tgrossma    += newsalry.pm_actbasic.to_f
     tarears     += newsalry.pm_arear.to_f
     tmabasic    += newsalry.pm_basic.to_f
     tlicamt     += newsalry.pm_ded_licemployee.to_f
     tbuldamt    += newsalry.pm_dedaccomodatamount.to_f
     telectric   += newsalry.pm_ded_electricamount.to_f
     trepaid     += newsalry.pm_ded_repaidadvance.to_f
     thealth     += newsalry.pm_ded_healthsewdarpay.to_f
     tincomtax   += newsalry.pm_totaltds.to_f
     tdeduction  += newsalry.pm_totaldeduction.to_f
     tnetpay     += newsalry.pm_netpay.to_f
     tloans      += newsalry.pm_ded_repaidloan.to_f

     tldeductft     += newsalry.pm_dedfirst.to_f
     tldeductsec    += newsalry.pm_dedsecond.to_f
     tlallown1      += newsalry.pm_allowancefirst.to_f
     tlallown2      += newsalry.pm_allowancesecond.to_f
     
     data4 += ([
       [{:content =>mycount.to_s}, {:content =>"<b>"+newsalry.pm_sewacode.to_s+"</b>"+"\n"+newsalry.sw_sewadar_name.to_s+"\n"+newsalry.deprtment.to_s,:inline_format => true}, {:content =>newsalry.pm_workingday.to_s+"\n"+newsalry.pm_paidleave.to_s+"\n"+newsalry.pm_hl.to_s+"\n"+newsalry.pm_wo.to_s}, {:content =>newsalry.pm_absent.to_s+"\n<b>"+newsalry.pm_paydays.to_s+"</b>\n"+newsalry.pm_monthday.to_s}, {:content =>currency_formatted(newsalry.pm_actbasic).to_s}, {:content =>currency_formatted(newsalry.pm_arear).to_s}, {:content =>currency_formatted(newsalry.pm_basic).to_s+"\n"+currency_formatted(newsalry.pm_allowancefirst).to_s+"\n"+currency_formatted(newsalry.pm_allowancesecond).to_s},{:content =>currency_formatted(newsalry.pm_ded_licemployee).to_s+"\n"+currency_formatted(newsalry.pm_dedaccomodatamount).to_s+"\n"+currency_formatted(newsalry.pm_ded_electricamount).to_s}, {:content =>currency_formatted(newsalry.pm_ded_repaidadvance).to_s+"\n"+currency_formatted(newsalry.pm_ded_repaidloan).to_s+"\n"+currency_formatted(newsalry.pm_ded_healthsewdarpay).to_s+"\n"+newsalry.pm_totaltds.to_s+"\n"+newsalry.pm_dedfirst.to_s+"\n"+newsalry.pm_dedsecond.to_s}, {:content =>currency_formatted(newsalry.pm_totaldeduction).to_s}, {:content =>currency_formatted(newsalry.pm_netpay).to_s},{:content =>"\n"+"\n"+"\n"+"\n"+newsalry.bankaccount.to_s}]

       ])
     mycount +=1
end
end
table([] + data4,:width =>760)  do
style row(0).column(0..1),  :align=>:left
style row(1).column(2..10),  :align=>:right
style row(0),  :size => 10
style row(1..10000),  :size => 8,:inline_format=>:true
row(0..1).background_color = '87CEEB'
style column(0), :width =>40
style column(1), :width =>125
style column(7..8), :width =>60
#style column(7), :width =>95
style column(4), :width =>64

style column(9), :width =>66
style column(2..3), :width =>50
style column(5), :width =>47
style column(6), :width =>60
style column(10), :width =>55
style column(11), :width =>83
style row(1), :size => 8
#row(1).column(0).font_style = :bold
#row(1).column(2).font_style = :bold
row(0..1).font_style = :bold
style row(0).column(2..3), :align=>:center
style row(0).column(5..6), :align=>:center
style row(0).column(7..8), :align=>:center
style row(2..5000).column(0..1),  :align=>:left
style row(2..5000).column(2..11),  :align=>:right

#style row(0..3), :border_width => 0

self.header=2
end






data6 = ([
  [{:content =>"Total"}, {:content =>""}, {:content =>tworkingday.to_s+"\n"+tpaidleave.to_s+"\n"+thalfleave.to_s+"\n"+tweeklyoff.to_s}, {:content =>tabsent.to_s}, {:content =>currency_formatted(tgrossma).to_s}, {:content =>currency_formatted(tarears).to_s},{:content =>currency_formatted(tmabasic).to_s},{:content =>currency_formatted(tlicamt).to_s+"\n"+currency_formatted(tbuldamt).to_s+"\n"+currency_formatted(telectric).to_s}, {:content =>currency_formatted(trepaid).to_s+"\n"+currency_formatted(tloans).to_s+"\n"+currency_formatted(thealth).to_s+"\n"+currency_formatted(tincomtax).to_s}, {:content =>currency_formatted(tdeduction).to_s}, {:content =>currency_formatted(tnetpay).to_s},{:content =>""}],
 
      ])
table([] + data6,:width =>760)  do
style row(0),  :size => 10, :align=>:right
style row(1..5000),  :size => 10, :align=>:left
style column(0), :width =>40
style column(1), :width =>125
style column(7..8), :width =>60
#style column(7), :width =>95
style column(4), :width =>64

style column(9), :width =>66
style column(2..3), :width =>50
style column(5), :width =>47
style column(6), :width =>60
style column(10), :width =>55
style column(11), :width =>83
#row(1).column(0).font_style = :bold
#row(1).column(2).font_style = :bold
row(0..1).font_style = :bold
#style row(0..5000), :border_width => 0
style column(0), :border_left_width => 1
style column(9), :border_right_width => 1
#style column(0..8), :border_right_width => 0
style row(0..5000), :border_bottom_width => 1
end

# repeat :all do
# text"WD- Working Days, PL- Paid Leaves, HL- Holiday, WO- Week Off, ABS- Absent, PD- Paid Days, MD- Month Days",:align=>:center,:size=> 8
# end
# newlengths =  @salary ?  @salary.length : 0
# if newlengths.to_i >100 && newlengths.to_i <200
#   newlengths = newlengths.to_i+100
# elsif newlengths.to_i >200
#   newlengths = newlengths.to_i+40  
# else
#   newlengths = 200
# end

# move_down newlengths\
Time.zone = "Kolkata"
billtimes = Time.zone.now.strftime('%I:%M%p')


repeat :all do
  text_box"WD- Working Days, PL- Paid Leaves, HL- Holiday, WO- Week Off, ABS- Absent, PD- Paid Days, MD- Month Days",:size=> 8,:align=>:center, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width

  text_box "<b>*This document is computer generated and does not require the signature</b>",:inline_format=> true , :size => 10, size: 7, align: :center, :at => [bounds.left, bounds.bottom-10], :height => 100, :width => bounds.width
  text_box "Generated on : "+format_oblig_date(Date.today).to_s+" "+billtimes.to_s ,:font_style=>:bold, :size => 10, size: 7, align: :right, :at => [bounds.left, bounds.bottom-10], :height => 100, :width => bounds.width
  
end
page_count.times do |i|
  go_to_page(i+1)
  move_down  40
  bounding_box [bounds.left - 5, bounds.top + 25], :width  => bounds.width do
  move_down 10
  text "Page : #{i+1} / #{page_count}", :size => 10,:align => :right
end

end
   
  end
  def selected_month_listed_data(months)
    monthsstr = ""
    if  months.to_i == 1
         monthsstr = "January"
    elsif  months.to_i == 2
         monthsstr = "February"
    elsif  months.to_i == 3
         monthsstr = "March"
    elsif  months.to_i == 4
         monthsstr = "April"
    elsif  months.to_i == 5
         monthsstr = "May"
    elsif  months.to_i == 6
         monthsstr = "June"
    elsif  months.to_i == 7
         monthsstr = "July"
    elsif  months.to_i == 8
         monthsstr = "August"
    elsif  months.to_i == 9
         monthsstr = "September"
    elsif  months.to_i == 10
         monthsstr = "October"
    elsif  months.to_i == 11
         monthsstr = "November"
    elsif  months.to_i == 12
         monthsstr = "December"
    end
    return monthsstr

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
        amts = 0
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