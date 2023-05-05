# To change this template, choose Tools | Templates
# and open the template in the editor.

class ArrivalsummarylocPdf < Prawn::Document
    def initialize(attendance,compdetail,heads,uRl,inchrch)
      super(:top_margin=>5,:page_size => "A4" )
      @attendance  = attendance
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
      # newcompdteail =  @compDetail.cmp_addressline1.to_s+((@compDetail.cmp_addressline1.to_s.length.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline2.to_s+((@compDetail.cmp_addressline2.to_s.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline3.to_s
        
      #   if @compDetail.cmp_logos.to_s.length >1
      #     @filesExt = Rails.root.join "public", "images", "logo",@compDetail.cmp_logos.to_s
      #     if File.exist?(@filesExt)
      #       image_path = {:image=>open(@uRl2.to_s+"images/logo/"+@compDetail.cmp_logos.to_s), :scale => @logoSize}           
      #     else
      #       image_path =''
      #     end
      #  end


      image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
      data1 = ([
         [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\n"+@compDetail.cmp_typeofbussiness.to_s+",\n"+@compDetail.cmp_addressline2.to_s+",\n"+@compDetail.cmp_addressline3.to_s, :inline_format=> true , :size => 10}],
      ])



        table([] + data1,:width =>528)  do
          style row(0), :align=>:left, :border_width => 0
          style column(0), :width     => 60
          style column(2), :width     => 100
          
        end
  
    tpresents   = 0
    tabsents    = 0
    tonleaves   = 0
    tstrength   = 0

   move_down 20
   text "Location Wise Arrival Report"
          move_up 12
          text "Print Date : "+format_oblig_date(Date.today).to_s, :size => 10, :align=>:right
tpresents   = 0
  tabsents    = 0
  tonleaves   = 0
  tstrength   = 0
  data4 = ([
    [{:content =>"Location"}, {:content =>"Total Strength"},   {:content =>"Present"},   {:content =>"Absent"},   {:content =>"On Leave"}, {:content =>"Present(%)"}],
    
    ])
    if @attendance && @attendance.length >0
      @attendance.each do |newpds|
        tpresents   += newpds.presents.to_f
        tabsents    += newpds.absents.to_f
        tonleaves   += newpds.onleave.to_f
        tstrength   += newpds.totalstrengthm.to_f
        percentage  = newpds.presents.to_f >0 ? (newpds.presents.to_f/newpds.totalstrengthm.to_f)*100 : 0
        percentage  = currency_formatted(percentage)
        percentage  = percentage.to_f > 0 ? percentage : '0.00'

data4 += ([
[{:content =>newpds.location.to_s}, {:content =>newpds.totalstrengthm.to_s}, {:content =>newpds.presents.to_s},   {:content =>newpds.absents.to_s},   {:content =>newpds.onleave.to_s}  ,{:content =>percentage.to_s}],

])
end
end
  table([] + data4,:width =>528)  do
  style row(0),  :size => 10, :align=>:left
  style row(1..5000),  :size => 10, :align=>:left
  style row(1..5000).column(1..5), :align=>:right
  row(0).background_color = '87CEEB'
  # row(0..1).background_color = '153084'
  # row(0..1).text_color = "FFFFFF"
  style column(0), :width =>110
  style column(1), :width =>88
  style column(2), :width =>80
  style column(3), :width =>80
  style column(4), :width =>82
  style column(5), :width =>88
  # style column(6), :width =>49
  # style column(7), :width =>49
  
  #row(1).column(0).font_style = :bold
  #row(1).column(2).font_style = :bold
  row(0).font_style = :bold
  # style column(2..4), :align=>:right
  end
  data5 = []
  mycount    = 1
  nettotals  = 0
  
  grandpercenatge = tpresents.to_f >0 ?  (tpresents.to_f/tstrength.to_f)*100 : 0
  grandpercenatge  = currency_formatted(grandpercenatge)
  grandpercenatge  = grandpercenatge.to_f > 0 ? grandpercenatge : '0.00'
  data6 = ([
   [{:content =>"Total"}, {:content =>(tstrength.to_i).to_s}, {:content =>tpresents.to_s}, {:content =>tabsents.to_s},{:content =>tonleaves.to_s}, {:content =>grandpercenatge.to_s}],
   
        ])
  table([] + data6,:width =>528)  do
  style row(0),  :size => 10, :align=>:left
  
  style row(0),  :size => 10, :align=>:left
  style row(1..5000),  :size => 10, :align=>:left
  style column(0), :width =>110
  style column(1), :width =>88
  style column(2), :width =>80
  style column(3), :width =>80
  style column(4), :width =>82
  style column(5), :width =>88
  style column(2..6), :align=>:right
  row(0..1).font_style = :bold
  #style row(0..5000), :border_width => 0
  style column(0), :border_left_width => 1
  style column(9), :border_right_width => 1
  #style column(0..8), :border_right_width => 0
  style row(0..5000), :border_bottom_width => 1
  end
  
  
  
  Time.zone = "Kolkata"
billtimes = Time.zone.now.strftime('%I:%M%p')


repeat :all do
  text_box "<b>*This document is computer generated and does not require the signature</b>",:inline_format=> true , :size => 10, size: 7, align: :center, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
  text_box "Generated on : "+format_oblig_date(Date.today).to_s+" "+billtimes.to_s ,:font_style=>:bold, :size => 10, size: 7, align: :right, :at => [bounds.left, bounds.bottom], :height => 100, :width => bounds.width
  
end
    page_count.times do |i|
                go_to_page(i+1)
                bounding_box [bounds.left, bounds.top + 5], :width  => bounds.width do
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