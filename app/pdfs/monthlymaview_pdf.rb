# To change this template, choose Tools | Templates
# and open the template in the editor.

class MonthlymaviewPdf < Prawn::Document
  def initialize(salary,compdetail,heads,uRl,inchrch)
    super(:top_margin=>20,:page_size => "A4" )
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
  [{:content =>"S No."}, {:content =>"Sewadar Code\n Old Code"},   {:content =>"Name"}, {:content =>"Department"},{:content =>"Category"}, {:content =>"Amount"}],
  
  ])

if @salary && @salary.length >0
         @salary.each do |newsalry|          
          
          data5 += ([
            [{:content =>mycount.to_s}, {:content =>newsalry.sw_sewcode.to_s+"\n"+newsalry.sw_oldsewdarcode.to_s},{:content =>newsalry.sw_sewadar_name.to_s}, {:content =>newsalry.departname.to_s}, {:content =>newsalry.sw_catgeory.to_s}, {:content =>currency_formatted(newsalry.so_basic).to_s}]

            ])
          mycount +=1
     end
end

table([] + data5,:width =>528)  do

style row(1..10000),  :size => 9, :align=>:left
style row(0),  :size => 10, :align=>:left
style column(0), :width =>40
style column(1), :width =>75
style column(2), :width =>133
style column(3), :width =>130
style column(4), :width =>80
style column(5), :width =>70
style column(4), :align =>:right
style column(0), :border_left_width => 1
style column(9), :border_right_width => 1
#style column(0..8), :border_right_width => 0
style row(0..5000), :border_bottom_width => 1
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