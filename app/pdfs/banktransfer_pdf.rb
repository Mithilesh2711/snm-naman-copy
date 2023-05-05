# To change this template, choose Tools | Templates
# and open the template in the editor.

class BanktransferPdf < Prawn::Document
  def initialize(salary,compdetail,url,names,gsess)
    super(:top_margin=>30,:bottom_margin=>30,:page_size => "A4" )
    @salary     = salary
    @compDetail = compdetail
    @heads      = nil
    @uRl2       = url
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5
    @gsess      = gsess
    @Months     = gsess[:my_sl_months]
    @MyYears    = gsess[:my_sl_years] 
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
end


move_down 20
data2 = ([
  [{:content=>"Bank Transfer Detail"},{:content=>"Print Date : "+format_oblig_date(Date.today).to_s}]
  ])
  table([] + data2,:width =>528)  do
    style column(0), :width =>250,:border_width=> 0
    style column(1), :width =>278,:border_width=> 0,:align=>:right,:size=>9
  end
  
  data4     = []
  mycount    = 1
  nettotals  = 0
  matotal    = 0
  tdstotal   = 0
  othtotal   = 0
  @txnetamt    = 0

data4 = ([
  [{:content =>"S.NO. "},{:content =>"Name "},{:content =>" Bank Name"}, {:content =>"Account No.  "}, {:content =>"IFSC Code"}, {:content =>"Net Payable\n "+get_number_month_data(@Months).to_s+"-"+@MyYears.to_s}],
  
  ])


    i = 1
  if @salary && @salary.length >0
   
      @salary.each do |newbanks|
        @txnetamt =  @txnetamt.to_f+newbanks.pm_netpay.to_f.round(0)
          data4 += ([
            [{:content =>i.to_s},{:content =>newbanks.sw_sewadar_name.to_s},{:content =>newbanks.skb_bank.to_s},{:content =>newbanks.skb_accountno.to_s}, {:content =>newbanks.skb_ifccocde.to_s}, {:content =>currencyformatted_round(newbanks.pm_netpay).to_s}],
             
            ])
            i +=1
          end
  end    
table([] + data4,:width =>528)  do
style row(0).column(0..9),  :size => 9, :align=>:center
style row(1..5000),  :size => 8, :align=>:left
  style row(0..5000).column(0),   :width => 40
  style row(0..5000).column(1),   :width => 120
  style row(0..5000).column(2),   :width => 95
  style row(0..5000).column(3),   :width => 88
  style row(0..5000).column(4),   :width =>  95
  style row(0..5000).column(5),   :width => 90
  style row(1..5000).column(0..4),  :size => 9, :align=>:center
  style row(1..5000).column(5),  :size => 9, :align=>:right


row(0).font_style = :bold
self.header= true
end

      
        data5 = ([
          [{:content =>"<b>Total</b>",:inline_format=> true},{:content =>""},{:content =>""},{:content =>""}, {:content =>""}, {:content =>"<b>"+currencyformatted_round( @txnetamt).to_s+"</b>",:inline_format=> true}],
           
          ])  
     

table([] + data5,:width =>528)  do
  style row(0..5000).column(0..4),  :size => 9, :align=>:center
  style row(0..5000).column(5),  :size => 9, :align=>:right
  style row(0..5000).column(0),   :width => 40
  style row(0..5000).column(1),   :width => 120
  style row(0..5000).column(2),   :width => 95
  style row(0..5000).column(3),   :width => 88
  style row(0..5000).column(4),   :width =>  95
  style row(0..5000).column(5),   :width => 90
  
  

 
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
   private
   def currencyformatted_round(amt)
        amts = 0
        if amt!=nil && amt!=''
          amts = "%.2f" % amt.to_f
        end
        return amts.to_f.round(0)
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