# To change this template, choose Tools | Templates
# and open the template in the editor.

class MonthlyallowancePdf < Prawn::Document
  def initialize(salary,compdetail,heads,uRl,inchrch)
    super(:top_margin=>5,:page_size => "A4" )
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
           [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\nAddress:"+@compDetail.cmp_addressline1.to_s+"\n"+"Contact No : "+@compDetail.cmp_cell_number.to_s, :inline_format=> true , :size => 10}, {:content =>"Date : "+format_oblig_date(Date.today).to_s, :inline_format=> true, :size => 9}],
        ])


  table([] + data1,:width =>528)  do
    style row(0), :align=>:left, :border_width => 0
    style column(0), :width     => 60
    style column(2), :width     => 100
    
  end


 move_down 10
 text "Allowance For the month of "+@salary[0].pm_paymonth.to_s+" "+@salary[0].pm_payyear.to_s
data4 = ([
  [{:content =>"S No.", :inline_format=> true ,:rowspan=>2}, {:content =>"Sewadar Code\nName\nDepartment", :inline_format=> true ,:rowspan=>2},   {:content =>"Fix Arrear", :inline_format=> true ,:colspan=>2,:rowspan=>2},{:content =>"Previous\n Arrear", :inline_format=> true ,:rowspan=>2}, {:content =>"Total", :inline_format=> true ,:rowspan=>2}],
  
  ])
table([] + data4,:width =>410)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
row(0..1).background_color = '87CEEB'
style column(0), :width =>40
style column(1), :width =>120
style column(7..8), :width =>70

#row(1).column(0).font_style = :bold
#row(1).column(2).font_style = :bold
row(0..1).font_style = :bold
style row(0).column(2..3), :align=>:center
style row(0).column(5..6), :align=>:center
style row(0).column(7..8), :align=>:center
#style row(0..3), :border_width => 0
end
data5      = []
mycount    = 1
nettotals  = 0
prevarear  = 0
fixarear   = 0

if @salary && @salary.length >0
         @salary.each do |newsalry|          
          nettotals     += ( newsalry.pm_arear.to_f+newsalry.pm_fixarear.to_f).to_f
          totals        = ( newsalry.pm_arear.to_f+newsalry.pm_fixarear.to_f).to_f
          prevarear     += newsalry.pm_arear.to_f
          fixarear      += newsalry.pm_fixarear.to_f
          data5 += ([
            [{:content =>mycount.to_s}, {:content =>newsalry.pm_sewacode.to_s+"\n"+newsalry.sw_sewadar_name.to_s+"\n"+newsalry.deprtment.to_s},{:content =>currency_formatted(newsalry.pm_fixarear).to_s},  {:content =>currency_formatted(newsalry.pm_arear).to_s}, {:content =>currency_formatted(totals).to_s}]

            ])
          mycount +=1
     end
end
#data5 += ([
#
#  [{:content =>"2"}, {:content =>"002\nUmesh\n20202020\nHOD"}, {:content =>"20"}, {:content =>"20"}, {:content =>"100"}, {:content =>"20"},{:content =>"200000"}, {:content =>"20\n10\n100"}, {:content =>"20\n10\n100\n30"}, {:content =>"20,000"}, {:content =>"20,000"},{:content =>""}]
#  ])
table([] + data5,:width =>410)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
style column(0), :width =>40
style column(1), :width =>120
style column(2), :width =>80
style column(3), :width =>80
style column(4), :width =>90
style column(0), :border_left_width => 1
style column(9), :border_right_width => 1
#style column(0..8), :border_right_width => 0
style row(0..5000), :border_bottom_width => 1
end



data6 = ([
 [{:content =>"Grand Total"}, {:content =>""}, {:content =>currency_formatted(fixarear).to_s }, {:content =>currency_formatted(prevarear).to_s }, {:content =>currency_formatted(nettotals).to_s}],
 
      ])
table([] + data6,:width =>410)  do
style row(0),  :size => 10, :align=>:left
style row(1..5000),  :size => 10, :align=>:left
style column(0), :width =>40
style column(1), :width =>120
style column(2), :width =>80
style column(3), :width =>80
style column(4), :width =>90

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
move_down 30
   page_count.times do |i|
              go_to_page(i+1)
              bounding_box [bounds.left, bounds.top + 10], :width  => bounds.width do
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