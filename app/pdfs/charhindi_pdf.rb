# To change this template, choose Tools | Templates
# and open the template in the editor.

class CharhindiPdf < Prawn::Document
    def initialize(invoice,compDetail,uRl,username,inchargename)
      super(:top_margin=>5,:page_size =>"A4",:border_width => 1 )
      @Receipt      = invoice
      @compDetail   = compDetail
      @username     = username
      @inchargename = inchargename
      @uRl2         = uRl
      @uRl          = Rails.root.join "public"
      @logoSize     = 0.5
      #@tnetamt      = @Receipt.vd_reqamount.round(0)
      line_items
      
   end
  
  
  
    def count_mcell
    @count_cell ||= 0
    @count_cell = @count_cell+1
  end
    def line_items
      move_down 40
      data0 = ([
        [{:content => " तिथिः "+format_oblig_date(Date.today).to_s, :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" , :size => 12}],
      ])
      table([] + data0,:width =>523)  do
        style row(0), :align=>:right, :border_width => 0
        
      end
      move_down 30
      image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"),:scale => @logoSize,:rowspan=>6,:border_width=>1}
      data1 = ([
          [{:content => "संत निरंकारी मंडल (रजि.)"+"\nसंत निरंकारी कलोनी"+"\nदिल्ली-110009", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" , inline_format: true , :size => 12}],
        ])
  
          
  table([] + data1,:width =>523)  do
      style row(0), :align=>:center, :border_width => 0
      
    end
  
    move_down 5
  data2 = ([
      [{:content =>"ब्राॅंच एवं जोन: "+"<u>State Bank of India, Subhash Nagar</u>", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:inline_format=>:true}],
      ])
  table([] + data2,:width=>523)  do
      style row(0),  :size => 10, :align=>:center
      style column(0..6), :border_width => 0
      cells.padding = 3
    end
  
    data6 = ([
      [{:content=>"चरित्र प्रमाण पत्र", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:inline_format=>:true,:align=>:center}],
      ])
  table([] + data6, :width=>523)  do
      style row(0..3),  :size => 14,:border_width=>0
      style row(1..100),  :size => 10
      cells.padding = 2
    end
  
    move_down 20
    data7 = ([
      [{:content=>"यह प्रमाणित किया जाता हैं कि श्री/ श्रीमति ........................................................ पुत्र/पुत्री...................................... पता................................................................................................... को मैं व्यक्तिगत रूप से ................ वषों से जानता हूॅं। वह संत निरंकारी मिशन के अनुयायी हैं और उन्होंनेे सन् ............. में बहृमज्ञान प्राप्त किया है। वह एक सम्मानित परिवार से हैं और चरित्रवान हैं। उनका विनम्र स्वभाव सेवा के लिए उपयुक्त हैं।", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:inline_format=>:true}],
      [{:content=>"\nयह भी प्रमाणित किया जाता हैं कि मैं उनके बारे में जानता हूॅं और वह किसी भी प्रकार की नशीली वस्तु का सेवन नहीं करते हैं। वह शारीरिक और मानसिक रूप से सेवा के लिए स्वस्थ हैं।", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" }]
      ])
  table([] + data7, :width=>523)  do
      style row(0..3),  :size => 12,:border_width=>0
      cells.padding = 2
    end
  
    move_down 70
    data10 = ([
      [{:content=>"मुखीे के हस्ताक्षर एवं स्टाॅम्प ", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" },{:content=>"संयोजक के हस्ताक्षर एवं स्टाॅम्प", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" },{:content=>"जोनल इंचार्ज के हस्ताक्षर एवं स्टाॅम्प", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" }],
      ])
  table([] + data10, :width=>523)  do
      style row(0..3),  :size => 10,:border_width=>0,:align=>:center
      style row(1..100),  :size => 10
      cells.padding = 2
    end
  
    move_down 40
    data11 = ([
      [{:content=>"नोटः यदि उपरोक्त सेवादार ब्राॅंच में किसी सेवा में योगदान दे रहें है तो कृपया सेवा का विवरण और सेवादार के योग्यता पर रिपोर्ट दें।", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" }]
      ])
  table([] + data11, :width=>523)  do
      style row(0),  :size => 10,:border_width=>0,:align=>:center
      cells.padding = 2
    end
    
  
  end
  
  
  
  private
  def number_currency_in_words
     to_words(@tnetamt.to_f)  
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
     def currency_formatted(amt)
          amts = ''
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