# To change this template, choose Tools | Templates
# and open the template in the editor.

class PendingadvancedetailPdf < Prawn::Document
  def initialize(salary,compdetail,heads,uRl,inchrch)
    super(:top_margin=>20,:page_size => "A4",:page_layout => :landscape )
    @salary     = salary
    @compDetail = compdetail
    @heads      = heads
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5
    @inchrch    = inchrch
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


  table([] + data1,:width =>528)  do
    style row(0), :align=>:left, :border_width => 0
    style column(0), :width     => 60
    style column(2), :width     => 100
    
  end


 move_down 10
#  text "Health Deduction For the month of "+@salary[0].pm_paymonth.to_s+" "+@salary[0].pm_payyear.to_s
        move_up 12
        text "Date : "+format_oblig_date(Date.today).to_s, :size => 10, :align=>:right


data5 = []
mycount    = 1

data5 = ([
  [{:content =>"S No."},{:content =>"Request No.\nDate Of Request\nAdvance Type"},{:content =>"Sewadar Code\n Old Code"},   {:content =>"Sewadar Name\nSewadar Department\nCategory"}, {:content =>"Date Of Joining\nDate Of Superannuaton"},{:content =>"Advance Amount\n Installment"},  {:content =>"Current Outstanding\nNo. Of Installments left\nLast Installment Date"}, {:content =>"Purpose\n Remark"}, {:content =>"Gurantor's Name"}],
  
  ])
  if @salary && @salary.length >0
    @salary.each do |newadv|                  
      requestype = ""
      if newadv.al_requesttype.to_s == 'Loan'
       requestype   = "Advance upto 60k"
      elsif newadv.al_requesttype.to_s == 'Advance'
       requestype = "MA Advance"
      else
       totaladvan   = newadv.al_advanceamt.to_f+newadv.al_loanamount.to_f
       requestype = newadv.al_requesttype
      end
      leftinstalment = 0
      
      if newadv.al_installpermonth.to_f >0 && newadv.al_balances.to_f >0
      totalinstalment = newadv.al_installpermonth
      remainimonths   = newadv.al_balances.to_f >0 ?  (newadv.al_balances.to_f/totalinstalment.to_f) : 0
      leftinstalment  = remainimonths.to_f>0  ? remainimonths.to_i :  0 
      end
      leftinstdate    = newadv.leftinstallmentdate   
          data5 += ([
            [{:content =>mycount.to_s}, {:content =>newadv.al_requestno+"\n"+formatted_date(newadv.al_requestdate)+"\n"+requestype.to_s},{:content =>newadv.al_sewadarcode+"\n"+newadv.sw_oldsewdarcode}, {:content =>newadv.sw_sewadar_name+"\n"+newadv.departname+"\n"+newadv.categoryname},  {:content =>formatted_date(newadv.sw_joiningdate)+"\n"+formatted_date(newadv.so_superannuationdate)}, {:content =>currency_formatted(totaladvan).to_s+"\n"+currency_formatted(newadv.al_installpermonth).to_s}, {:content =>currency_formatted(newadv.al_balances).to_s+"\n"+leftinstalment.to_s+"\n"+formatted_date(leftinstdate).to_s}, {:content =>newadv.al_purpose+"\n"+newadv.al_remark}, {:content =>newadv.al_guarantorname}]

            ])
          mycount +=1
     end
end

table([] + data5,:width =>770)  do

style row(1..10000),  :size => 9, :align=>:left
style row(0),  :size => 9, :align=>:left
style column(0), :width =>40
style column(1), :width =>80
style column(2), :width =>70
style column(3), :width =>140
style column(4), :width =>90
style column(5), :width =>90
style column(6), :width =>90
style column(7), :width =>90
style column(8), :width =>80

style column(4), :align =>:right

#style column(0..8), :border_right_width => 0

style column(3..5), :align =>:center
row(0).background_color = '87CEEB'
self.header = true
end



# data6 = ([
#  [{:content =>"Grand Total"}, {:content =>""}, {:content =>"" }, {:content =>currency_formatted(nettotals).to_s}, {:content =>currency_formatted(nettotals).to_s}],
 
#       ])
# table([] + data6,:width =>528)  do
# style row(0),  :size => 10, :align=>:left
# style row(1..5000),  :size => 10, :align=>:left
# style column(0), :width =>70
# style column(1), :width =>220
# style column(2), :width =>80
# style column(3), :width =>80
# style column(4), :width =>78
# style column(2..4), :align =>:right
# row(0..1).font_style = :bold
# #style row(0..5000), :border_width => 0
# style column(0), :border_left_width => 1
# style column(9), :border_right_width => 1
# #style column(0..8), :border_right_width => 0
# style row(0..5000), :border_bottom_width => 1
# end



Time.zone = "Kolkata"
billtimes = Time.zone.now.strftime('%I:%M%p')


repeat :all do
  text_box "<b>*This document is computer generated and does not require the signature</b>",:inline_format=> true , :size => 10, size: 7, align: :center, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
  text_box "Generated on : "+format_oblig_date(Date.today).to_s+" "+billtimes.to_s ,:font_style=>:bold, :size => 10, size: 7, align: :right, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
  
end
move_down 30
   page_count.times do |i|
              go_to_page(i+1)
              bounding_box [bounds.left, bounds.top + 20], :width  => bounds.width do
              move_down 10
              text "Page : #{i+1} / #{page_count}", :size => 10,:align => :right
           end

          end

  
   
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