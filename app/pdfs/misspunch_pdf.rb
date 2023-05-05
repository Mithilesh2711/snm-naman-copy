class MisspunchPdf < Prawn::Document
  def initialize(attendance,compdetail,uRl,rsss,oths)
    super(:margin_top=>20,:bottom_margin=>30,:page_size => "A4" )
    @attendance = attendance
    @compDetail = compdetail
    @heads      = nil
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5
    @rsss       = rsss
    line_items
    
 end

 
  def count_mcell
    @count_cell ||= 0
    @count_cell = @count_cell+1
end
  def line_items
      #   newcompdteail =  @compDetail.cmp_addressline1.to_s+((@compDetail.cmp_addressline1.to_s.length.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline2.to_s+((@compDetail.cmp_addressline2.to_s.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline3.to_s
        
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

  totwhrs     = 0
  totlathrs   = 0
  totearlyhrs = 0
  totovtime   = 0
  fwkhrs      = 0
  fwkmns      = 0
  fwlthrs     = 0
  fwlatmns    = 0
  fwearhrs    = 0
  fwearmns    = 0
  fwovthrs    = 0
  fwovtmns    = 0
  farrivalh   = 0
  farrivals   = 0
  fdephrs     = 0
  fdepmns     = 0
 move_down 20
 text "Miss Punch Report", :font_style => :bold
        move_up 12
        text "Print Date : "+format_oblig_date(Date.today).to_s, :size => 10, :align=>:right
data4 = ([
  [{:content =>"S No."}, {:content =>"Employee / Code Name"},   {:content =>"Location\nDepartment"},   {:content =>"Shift"},{:content =>"Arrival Time"}, {:content =>"Departure Time"}, {:content =>"Remark"}],
  
  ])
  if @attendance && @attendance.length >0
    @attendance.each do |newpds|
      newkhrs   =  get_calculated_hours_minute(newpds.al_workhrs,'H')
      newmnts   =  get_calculated_hours_minute(newpds.al_workhrs,'M')
      latehrs   =  get_calculated_hours_minute(newpds.al_latehrs,'H')
      latmints  =  get_calculated_hours_minute(newpds.al_latehrs,'M')
      earlyhrs  =  get_calculated_hours_minute(newpds.al_earlhrs,'H')
      earlymns  =  get_calculated_hours_minute(newpds.al_earlhrs,'M')
      vothrs    =  get_calculated_hours_minute(newpds.al_overtime,'H')
      ovtmns     = get_calculated_hours_minute(newpds.al_overtime,'M')
      
      arrvlh     = get_calculated_hours_minute(newpds.al_arrtime,'H')
      arrvls     = get_calculated_hours_minute(newpds.al_arrtime,'M')


      fwkhrs    += newkhrs.to_i
      fwkmns    += newmnts.to_i
      fwlthrs   += latehrs.to_i
      fwlatmns  += latmints.to_i 
      fwearhrs  += earlyhrs.to_i
      fwearmns  += earlymns.to_i
      fwovthrs  += vothrs.to_i
      fwovtmns  += ovtmns.to_i
      farrivalh  += arrvlh.to_i
      farrivals  += arrvls.to_i

       data4 += ([
         [{:content =>count.to_s}, {:content =>newpds.al_empcode+" / "++newpds.sw_sewadar_name.to_s},   {:content =>newpds.location.to_s+"\n"+newpds.mydepartment.to_s},   {:content =>newpds.al_shift.to_s},{:content =>newpds.al_arrtime.to_s},{:content =>newpds.al_latehrs.to_s}, {:content =>""}],
         
         ])
     end
 end
table([]+data4,:width =>528)  do
    style row(0),  :size => 8.5, :align=>:left
    style row(1..5000),  :size => 10, :align=>:left
    row(0).column(0..11).background_color = '87CEEB'
    # row(0..1).background_color = '153084'
    # row(0..1).text_color = "FFFFFF"
    style column(0), :width =>43
    style column(1), :width =>180
    style column(2), :width =>100
    style column(3), :width =>35
    style column(4), :width =>60
    style column(5), :width =>55
    style column(6), :width =>55
    #row(1).column(0).font_style = :bold
    row(0).column(0..11).font_style = :bold
    #row(0..1).font_style = :bold
    # style column(2..4), :align=>:right
end

mycount    = 1
nettotals  = 0

      newwkhrs  = convert_minute_hours_process(fwkhrs,fwkmns)
      newlthrs  = convert_minute_hours_process(fwlthrs,fwlatmns)
      newealhrs  = convert_minute_hours_process(fwearhrs,fwearmns)
      newovthrs = convert_minute_hours_process(fwovthrs,fwovtmns)   
      newarrvhrs = convert_minute_hours_process(farrivalh,farrivals)



# data6 = ([
#  [ {:content =>"Grand Total", :colspan => 2}, {:content =>"" }, {:content =>""}, {:content =>newarrvhrs.to_s}, {:content =>newlthrs.to_s}, {:content =>""}],
 
#       ])
# table([] + data6,:width =>528)  do
# style row(0),  :size => 10, :align=>:left
# style row(1..5000),  :size => 10, :align=>:left
# style column(0), :width =>43
# style column(1), :width =>180
# style column(2), :width =>100
# style column(3), :width =>35
# style column(4), :width =>60
# style column(5), :width =>55
# style column(6), :width =>55
# style column(2..4), :align=>:right
# row(0..1).font_style = :bold
# #style row(0..5000), :border_width => 0
# style column(0), :border_left_width => 1
# style column(9), :border_right_width => 1
# #style column(0..8), :border_right_width => 0
# style row(0..5000), :border_bottom_width => 1
# end



move_down 100
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

 ##########CALCULATION PROCESS ####################
 def convert_minute_hours_process(fwkhrs,fwkmns)
   wrkshrs = 0
  if fwkmns.to_i >=60
    nwhs = fwkmns.to_f/60
    nwhs  = currency_formatted(nwhs)
    wrkshrs = fwkhrs.to_f+nwhs.to_f
    nwrks = wrkshrs.to_s.split(".")
    if nwrks[1].to_i<10
      mns = ":0"+nwrks[1].to_s
      wrkshrs = nwrks[0].to_s+mns.to_s
    else
      wrkshrs = wrkshrs.to_s.gsub(".",":")
    end
  else
    if fwkmns.to_i <10
       wrkshrs = fwkhrs.to_s+":"+"0"+fwkmns.to_s
    else
      wrkshrs = fwkhrs.to_s+":"+fwkmns.to_s
    end
    
  end
  return wrkshrs

 end
 def get_calculated_hours_minute(times,type)
  fhrstime = 0
  if times != nil && times != ''
        vtms     = times.to_s.strip.split(":")
        nhrs     = vtms[0]
        nmnt     = vtms[1]
        if type == 'H'
           fhrstime =nhrs
        elsif type == 'M'
          fhrstime = nmnt
        end
  end
  return fhrstime
end

 ###########ATTENDANCE PROCESS_CALCULATION

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