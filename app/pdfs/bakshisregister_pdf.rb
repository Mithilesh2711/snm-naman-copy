# To change this template, choose Tools | Templates
# and open the template in the editor.

class BakshisregisterPdf < Prawn::Document
  def initialize(dataitem,compdetail,url,bakshis,names,gsess)
    super(:top_margin=>25,:bottom_margin=>25,:page_size => "A4",:page_layout => :landscape )
    @dataitem     = dataitem
    @compDetail = compdetail
    @chobj      = bakshis
    @heads      = nil
    @uRl2       = url
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5
    @gsess      = gsess
   
    line_items
    
    
 end

 
  
  def line_items
    image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
    data1 = ([
       [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\n"+@compDetail.cmp_typeofbussiness.to_s+",\n"+@compDetail.cmp_addressline2.to_s+",\n"+@compDetail.cmp_addressline3.to_s, :inline_format=> true , :size => 10}],
    ])
   

table([] + data1,:width =>528)  do
style row(0).column(0..1), :align=>:left, :border_width => 0
style column(0), :width     => 60
style column(2), :width     => 150
style row(0).column(2), :align=>:right, :border_width => 0
self.header=true
end
months  = ""
myyers  = ""
if @dataitem && @dataitem.length >0
     sptdate  =  @dataitem[0].bt_date.to_s.split("-")
     months   =  get_number_month_data(sptdate[1])
     myyers   =  sptdate[0]
end

 move_down 30
 data2 = ([
  [{:content=>"<b>Samagam Bakshis For the M/o "+months.to_s+"-"+myyers.to_s+"</b>"},{:content=>"Print Date : "+format_oblig_date(Date.today).to_s}]
  ])
  table([] + data2,:width =>770)  do
    style column(0), :width =>430,:border_width=> 0,:align=>:left,:size=>9,:inline_format=>:true
  
    style column(1), :width =>340,:border_width=> 0,:align=>:right,:size=>9
  end

    
  data4 = []
  mycount      = 1
  totalma      = 0
  totalbakshis = 0
data4 = ([
  [{:content =>"S.No"},{:content =>"Code"},{:content =>" Name"},{:content =>"Bank Name"},{:content =>"Account Number"},{:content =>"IFSC Code "},{:content =>"Accounting Department"}, {:content =>"D.O.J "}, {:content =>"As on  "+formatted_date(@chobj.bt_date).to_s}, {:content =>"Year Of Sewadar "}, {:content =>months.to_s+", " +@chobj.bt_year.to_s+"\nGross M.A"}, {:content =>"Samagam Bakshis"}],
  
  ])
  i = 1
  if @dataitem && @dataitem.length >0
     @dataitem.each do |newbkshis|
          stryrs     = newbkshis.bt_total_sewa.to_s.split("-")
          totalyears = stryrs[0]
          totalma    += currencyformatted_round(newbkshis.bt_ma).to_f
         totalbakshis += currencyformatted_round(newbkshis.bt_payamount).to_f
      data4 += ([
      [{:content =>i.to_s},{:content =>newbkshis.bt_sewacode.to_s},{:content =>newbkshis.bt_sewadarname.to_s},{:content=>newbkshis.bt_bankname.to_s},{:content=>newbkshis.bt_accountno.to_s},{:content=>newbkshis.bt_ifsccode.to_s},{:content =>newbkshis.bt_departname.to_s}, {:content =>formatted_date(newbkshis.bt_datejoining).to_s}, {:content =>formatted_date(newbkshis.bt_date).to_s}, {:content =>totalyears.to_s}, {:content =>currencyformatted_round(newbkshis.bt_ma).to_s}, {:content =>currencyformatted_round(newbkshis.bt_payamount).to_s}],
             
      ])
      i +=1
     end
end
table([] + data4,:width =>775)  do

  style row(1..5000),  :size => 8, :align=>:left
  style row(0).column(0),   :width => 35
  style row(0).column(1),   :width => 55
  style row(0).column(2),   :width => 80
  style row(0).column(3),   :width => 80
  style row(0).column(4),   :width => 85
  style row(0).column(5),   :width => 70
  style row(0).column(6),   :width => 85
  style row(0).column(7),   :width => 60
  style row(0).column(8),   :width => 60
  style row(0).column(9),   :width => 45
  style row(0).column(10),   :width =>65
  style row(0).column(11),   :width => 55
  self.header=true
  row(0).background_color = '87CEEB'
  style column(10..11),:align=>:right
  style column(3..9),  :size => 9, :align=>:center
  style row(0).column(0..12),  :size => 9, :align=>:center
  style column(0..12),  :size => 8
  row(0).font_style = :bold

end


data6 = ([
  [{:content =>" TOTAL",:colspan=>10}, {:content =>currencyformatted_round(totalma).to_s}, {:content =>currencyformatted_round(totalbakshis).to_s}],
 
      ])
      table([] + data6,:width =>775)  do
     
          style row(0..5000).column(0),  :size => 9, :align=>:left
          style row(0..5000).column(1..12),  :size => 9, :align=>:right
          style row(0).column(0),   :width => 35
          style row(0).column(1),   :width => 55
          style row(0).column(2),   :width => 80
          style row(0).column(3),   :width => 80
          style row(0).column(4),   :width => 85
          style row(0).column(5),   :width => 70
          style row(0).column(6),   :width => 85
          style row(0).column(7),   :width => 60
          style row(0).column(8),   :width => 60
          style row(0).column(9),   :width => 45
          style row(0).column(10),   :width =>65
          style row(0).column(11),   :width => 55
            
        row(0..1).background_color = '87CEEB'
        
        row(0..1).font_style = :bold
        
        end


        Time.zone = "Kolkata"
        billtimes = Time.zone.now.strftime('%I:%M%p')
        
        
        repeat :all do
          text_box "<b>*This document is computer generated and does not require the signature</b>",:inline_format=> true , :size => 10, size: 7, align: :center, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
          text_box "Generated on : "+format_oblig_date(Date.today).to_s+" "+billtimes.to_s ,:font_style=>:bold, :size => 10, size: 7, align: :right, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
        end
          page_count.times do |i|
                      go_to_page(i+1)
                      bounding_box [bounds.left, bounds.top + 25], :width  => bounds.width do
                      move_down 10
                      text "Page : #{i+1} / #{page_count}", :size => 10,:align => :right
                   end
        
                  end 

 
 
  end

  def get_number_month_data(months)
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
   def currencyformatted_round(amt)
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