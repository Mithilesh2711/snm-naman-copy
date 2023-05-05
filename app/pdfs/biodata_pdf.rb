# To change this template, choose Tools | Templates
# and open the template in the editor.

class BiodataPdf < Prawn::Document
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
    
    
    image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"),:scale => @logoSize,:rowspan=>6,:border_width=>1}
    data1 = ([
        [{:content => "<b>Sant Nirankari Mandal</b>"+"\nAddress : MANDALH.Q Nirankari Complex Delhi - 110019"+"\nContact No.: +91-933-939-3902", inline_format: true , :size => 10}],
      ])

        
table([] + data1,:width =>523)  do
    style row(0), :align=>:center, :border_width => 0
    
  end

  move_down 5
data2 = ([
    [{:content =>"Zone No."}, {:content =>""}, {:content =>"Branch"}, {:content =>""}, {:content =>"Date"}, {:content =>""}],
    ])
table([] + data2,:cell_style => {:inline_format => true })  do
    style row(0..3),  :size => 8, :align=>:left
    style row(0..3).column(0..6), :width =>70
    style column(0..6), :border_width => 0
    
    #row(0..1).column(0).font_style = :bold
    #cells.size = 9
    cells.padding = 3
  end
  
  move_down 5
data3 = ([
    [{:content=>"1."},{:content =>"Name of Sewadar (In Block Letter)",:colspan=>3},image_path],
    [{ :content=>""},{:content => "सेवादार का नाम", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>3}],
    [{:content=>"2."},{:content =>"Father’s/ Husband’s Name (In Block Letter)",:colspan=>3}],
    [{ :content=>""},{:content => " पिता/पति का नाम ", :font => @uRl.to_s+"/assets/fonts/Poppins-Light.ttf",:colspan=>3 }],
    [{:content=>"3."},{:content =>"Date of Birth: "+ "22 Jan 1996"},{:content => " Age "+"25"},{:content => " Gender "+"Male"}],
    [{ :content=>""},{:content => "जन्मतिथि", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" },{:content => "आयु", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" },{:content => "लिंग", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" }],
    [{:content=>"4."},{:content =>"Marital Status",:colspan=>4}],
    [{ :content=>""},{:content => "विवाहित/अविवाहित", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"5."},{:content =>"*Educational Qualification",:colspan=>4}],
    [{ :content=>""},{:content => "शैक्षणिक योग्यता", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"6."},{:content =>"(a) *Previous Experience",:colspan=>2},{:content=>"Reason for leaving",:colspan=>2}],
    [{ :content=>""},{:content => "पिछला अनुभव ", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>2},{:content => "छोड़ने की वजह", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>2}],
    [{:content=>""},{:content =>"(b) *Whether the Sewadar has rendered services in Govt./Semi Govt./Army/PSU (Yes/No)",:colspan=>4}],
    [{ :content=>""},{:content => "क्या सेवादार ने सरकारी/अर्ध सरकारी/आर्मी/पी.एस.यू. में सेवा प्रदान की है (हाॅं/नहीं)", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    [{:content=>""},{:content =>"(c) If yes, any retirement benefits are being availed (Yes)",:colspan=>4}],
    [{ :content=>""},{:content => "यदि हाॅं तो किसी भी सेवानिवृति का लाभ मिल रहा है (हाॅं/नहीं)द्ध", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>""},{:content =>"(d) If yes, what is the amount of pension? Please also mention if there is any other source of income",:colspan=>4}],
    [{ :content=>""},{:content => "यदि हाॅं तो कितनी पेन्शन या किसी अन्य स्रोत से आमदनी प्राप्त हो रही है, विवरण दें", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"7."},{:content =>"*Present Residential Address",:colspan=>4}],
    [{ :content=>""},{:content => "वर्तमान घर का पता", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    [{:content=>"8."},{:content =>"*Permanent Residential Address",:colspan=>4}],
    [{ :content=>""},{:content => "घर का स्थाई पता", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    [{:content=>""},{:content =>"(a) Do you have self owned house (Yes/No) "+"Yes "+"If yes, what is the area"+"",:colspan=>4}],
    [{ :content=>""},{:content => "क्या आपके पास अपना मकान है (हां/नहीं) ", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    [{:content=>""},{:content =>"(b) Address of the self-owned house",:colspan=>4}],
    [{ :content=>""},{:content => "अपने मकान का पता", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"9."},{:content =>"Telephone / Mobile No",:inline_format=>:true,:colspan=>2},{:content=>"E-mail Id",:inline_format=>:true,:colspan=>2}],
    [{ :content=>""},{:content => "फोन नं./मोबाइल नं.", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>2},{:content => "ई-मेल आईडी.", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>2}],
    [{:content=>"10."},{:content =>"Personal Mark for Identification",:inline_format=>:true,:colspan=>4}],
    [{ :content=>""},{:content => "शारीरिक पहचान चिन्ह ", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    [{:content=>"11."},{:content =>"*Bank Name and Branch"+"State Bank of India",:inline_format=>:true,:colspan=>2},{:content=>"A/c No.",:inline_format=>:true},{:content=>"IFSC Code",:inline_format=>:true,:border_width=>0}],
    [{ :content=>""},{:content => "बैंक का नाम और ब्राँच ", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>2},{:content => "अकाउंट न.", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf"}],
    [{:content=>"12."},{:content =>"*Aadhaar Card No",:inline_format=>:true,:colspan=>4}],
    [{ :content=>""},{:content => "आधार कार्ड न.", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"13."},{:content =>"Whether blessed with Brahm Gyan (if Yes, when, where and from whom)",:inline_format=>:true,:colspan=>4}],
    [{ :content=>""},{:content => "यदि बहृमज्ञान प्राप्त किया है (अगर हाॅं तो कब, कहां और किससे)", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"14."},{:content =>"Any other Sewa being rendered (such as Sewadal, SNCF etc)",:inline_format=>:true,:colspan=>4}],
    [{ :content=>""},{:content => "यदि अन्य सेवा में हैं तो विवरण दें", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf" ,:colspan=>4}],
    [{:content=>"15."},{:content =>"Details of Family Members rendering sewa in SNM",:inline_format=>:true,:colspan=>4}],
    [{ :content=>""},{:content => "स.नि.म. में सेवा कर रहे परिवार के सदस्यों का विवरण", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>4 }],
    ])
table([] + data3,:cell_style => {:inline_format => true })  do
    style row(0..500),  :size => 10, :align=>:left
    #style row(0..3).column(0), :width =>70
    style column(0..3), :border_width => 0

    #row(0..1).column(0).font_style = :bold
    #cells.size = 9
    cells.padding = 2
  end
  
  data4 = ([
    [{:content=>"Sr."},{:content =>"Name"},{:content =>"Date of Birth"},{:content =>"Gender"},{:content =>"Sewa"},{:content =>"Realtionship"}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    ])
table([] + data4, :width=>523)  do
    style row(0..500),  :size => 10, :align=>:left
    cells.padding = 2
  end

  move_down 20
  data5 = ([
    [{:content=>"<b>Detail of Dependent Member of Sewadar</b>",:inline_format=>:true,:colspan=>7,:align=>:center}],
    [{:content=>"Sr."},{:content =>"Name"},{:content =>"Date of Birth"},{:content =>"Gender"},{:content =>"Relationship"},{:content =>"Occupation"},{:content =>"Monthly income/Pension or any other earning"}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    ])
table([] + data5, :width=>523)  do
    style row(0),  :size => 12,:border_width=>0
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 20
  data6 = ([
    [{:content=>"<b>FOR SEWADAR WITH ACCOMMODATION AT BHAWAN</b>",:inline_format=>:true,:colspan=>7,:align=>:center}],
    [{:content=>"सतसंग भवन पर रहने वाले सेवादार के लिए", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>7,:align=>:center}],
    [{:content=>"<b>DETAILS OF FAMILY MEMBERS STAYING AT BHAWAN WITH THE SEWADAR\n(Only wife and two minor children can live with sewadar in bhawan)</b>",:inline_format=>:true,:colspan=>7,:align=>:center}],
    [{:content=>"सतसंग भवन पर रहने वाले सेवादार के परिवार का विवरण\n(केवल पत्नी और दो नाबालिक बच्चे ही भवन पर रह सकते है)", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>7,:align=>:center}],
    [{:content=>"Sr."},{:content =>"Name"},{:content =>"Gender"},{:content =>"Date of Birth"},{:content =>"Relationship"},{:content =>"Aadhar Card No."},{:content =>"Occupation"}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    [{:content=>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""},{:content =>""}],
    ])
table([] + data6, :width=>523)  do
    style row(0..3),  :size => 12,:border_width=>0
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 20
  data7 = ([
    [{:content=>"I hereby undertake that I or any of my dependent family members shall not indulge in alcohol/ drug addiction. Further, neither myself nor any of my family members/guest(s) staying in the premises will indulge in any illegal/ anti-social/criminal/immoral or defamatory/derogatory activity. 
    \nI declare that the facts stated above are true to the best of my knowledge",:inline_format=>:true,:colspan=>7}],
    ])
table([] + data7, :width=>523)  do
    style row(0..3),  :size => 12,:border_width=>0
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 20
  data7 = ([
    [{:content=>"मैं विश्वास दिलाता हूॅं कि मैं तथा मेेरे परिवार का कोई भी सदस्य शराब व अन्य नशीली वस्तुओं का सेवन नहीं करेगा। मैं तथा मेेरे परिवार का कोई भी सदस्य/परिसर में रहने वाला मेहमान किसी भी अवैध/असामाजिक/अनैतिक गतिविधियों में संलिप्त नही रहेगा । 
    \nमैं घोषणा करता/करती हूॅं कि उपरोक्त लिखित विवरण मेरी जानकारी के अनुसार सत्य है।", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf",:colspan=>7}],
    ])
table([] + data7, :width=>523)  do
    style row(0..3),  :size => 12,:border_width=>0
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 50
  data8 = ([
    [{:content=>"Signature of Concerned Sewadar"}],
    [{:content=>"(सेवादार के हस्ताक्षर)", :font => @uRl.to_s+"/assets/fonts/siddhanta.ttf"}],
    ])
table([] + data8, :width=>523)  do
    style row(0..3),  :size => 12,:border_width=>0,:align=>:right
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 50
  data9 = ([
    [{:content=>"Verified that the facts stated above are correct and sewadar is physically and mentally fit to perform the sewa of ____________________________ at Branch ____________________________ Zone No. _________________ The proposed Maintenance Allowance is ________________ __per month."}],
    ])
table([] + data9, :width=>523)  do
    style row(0..3),  :size => 10,:border_width=>0
    style row(1..100),  :size => 10
    cells.padding = 2
  end

  move_down 70
  data10 = ([
    [{:content=>"Signature of Mukhi/Sanyojak\nwith stamp"},{:content=>"Signature of Sanyojak\nwith stamp"},{:content=>"Signature of Zonal Incharge\nwith Stamp"}],
    ])
table([] + data10, :width=>523)  do
    style row(0..3),  :size => 10,:border_width=>0,:align=>:center
    style row(1..100),  :size => 10
    cells.padding = 2
  end

end



private
def number_currency_in_words
   to_words(@tnetamt.to_f)  
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