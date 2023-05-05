# To change this template, choose Tools | Templates
# and open the template in the editor.

class SewadartdsmonthlyPdf < Prawn::Document
  def initialize(salary,compdetail,url,names,gsess)
    super(:top_margin=>5,:page_size => "A4" )
    @salary     = salary
    @compDetail = compdetail
    @heads      = nil
    @uRl2       = url
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5
    @gsess      = gsess
    line_items
    
 end

 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
     
        image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
        data1 = ([
           [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\nAddress:"+@compDetail.cmp_addressline1.to_s+"\n"+"Contact No : "+@compDetail.cmp_cell_number.to_s, :inline_format=> true , :size => 10}],
        ])


  table([] + data1,:width =>528)  do
    style row(0), :align=>:left, :border_width => 0
    style column(0), :width     => 60
    style column(2), :width     => 100
    
  end

   monthsesh =  get_month_listed_data(@gsess["requestmonth"])
   

 move_down 10
 if @salary && @salary.length >0
     @salary.each do |newsalry|          
 text "<b>Sewadar TDS Yearly Summary</b>" , :inline_format=> :true, :align=> :center
 text "<b>Financial Year : "+@gsess["requestyear"].to_s+"</b>" , :inline_format=> :true, :align=> :center
 text "<b>For Month : "+monthsesh+","" "+newsalry.pm_payyear+"</b>" , :inline_format=> :true, :align=> :center
end
end
 data4 = ([
     [{:content =>"S No."},{:content =>"Sewadar Details"},{:content =>"Pan Number"},{:content =>"MA Amount"}, {:content =>"TDS Deduction"}],
     
     ])
table([] + data4,:width =>528)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
style row(0).column(0),   :width => 39
style row(0).column(1),   :width => 200
style row(0).column(2),   :width => 94, :align => :right
style row(0).column(3),   :width => 100 , :align => :right
style row(0).column(4),   :width => 95 , :align => :right
row(0..1).background_color = '87CEEB'

row(0..1).font_style = :bold

end

data5 = []
mycount    = 1
nettotals  = 0
matotal    = 0
tdstotal   = 0
othtotal   = 0

if @salary && @salary.length >0
         @salary.each do |newsalry|          
           nettotals     += newsalry.netpay.to_f
           matotal       += newsalry.myma.to_f
           tdstotal      += newsalry.totaltdsdeduct.to_f
           othtotal      += newsalry.otherdeduction.to_f
          # totals         = newsalry.pm_dedaccomodatamount.to_f
          referecode      = ""
           if newsalry.oldcode != nil && newsalry.oldcode != ''
            referecode = " ("+newsalry.oldcode.to_s+")"
           end

           data5 += ([
               [{:content =>mycount.to_s+"."}, {:content =>+newsalry.pm_sewacode.to_s+"\n"+newsalry.sewdarname.to_s+"\n"+newsalry.department.to_s},{:content =>newsalry.panno},{:content =>currency_formatted(newsalry.myma).to_s},  {:content =>currency_formatted(newsalry.totaltdsdeduct).to_s}]
   
               ])
             mycount +=1
        end
   end
table([] + data5,:width =>528)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
style column(2..4), :align => :right
style row(0..5000).column(0),   :width => 39
style row(0..5000).column(1),   :width => 200
style row(0..5000).column(2),   :width => 94, :align => :right
style row(0..5000).column(3),   :width => 100 , :align => :right
style row(0..5000).column(4),   :width => 95 , :align => :right

style column(0), :border_left_width => 1
style column(9), :border_right_width => 1
#style column(0..8), :border_right_width => 0
style row(0..5000), :border_bottom_width => 1
end



data6 = ([
     [{:content =>"Grand Total", :colspan => 2},{:content => ""}, {:content =>currency_formatted(matotal).to_s }, {:content =>currency_formatted(tdstotal).to_s}],
     
          ])
table([] + data6,:width =>528)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
style row(0).column(0),   :width => 39
style row(0).column(1),   :width => 200
style row(0).column(2),   :width => 94, :align => :right
style row(0).column(3),   :width => 100 , :align => :right
style row(0).column(4),   :width => 95 , :align => :right

row(0..1).font_style = :bold
#style row(0..5000), :border_width => 0
style column(0), :border_left_width => 1
style column(9), :border_right_width => 1
#style column(0..8), :border_right_width => 0
style row(0..5000), :border_bottom_width => 1
end



move_down 100
data9 = ([
  [{:content =>"*This document is computer generated and does not require the signature"}],
])
table([] + data9,:width =>523)  do
style row(0),  :size => 10, :align=>:left, :border_width => 0, :font_style => :bold
end
  page_count.times do |i|
              go_to_page(i+1)
              bounding_box [bounds.left, bounds.top + 5], :width  => bounds.width do
              move_down 10
              text "Page : #{i+1} / #{page_count}", :size => 10,:align => :right
           end

          end

  
   
  end
  
  def get_month_listed_data(months)
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
          amts = "%.2f" % amt.to_f
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