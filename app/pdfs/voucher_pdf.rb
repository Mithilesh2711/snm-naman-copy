# To change this template, choose Tools | Templates
# and open the template in the editor.

class VoucherPdf < Prawn::Document
  def initialize(invoice,compDetail,uRl,username,inchargename,myusercode)
    super(:top_margin=>5,:page_size =>"A4",:border_width => 1 )
    @Receipt      = invoice
    @compDetail   = compDetail
    @username     = username
    @inchargename = inchargename
    @uRl2         = uRl
    @myusercode   = myusercode
    @uRl          = Rails.root.join "public"
    @logoSize     = 0.5
    @tnetamt      = @Receipt.vd_reqamount.round(0)
    line_items   
    
    stroke_color '0000'
    stroke do
        # just lower the current y position      
        #horizontal_rule
        vertical_line   480, 780, :at=>[0]  ## 480 increase from bottom, 780 increase/decrease from top ### FOR LEFT SIDE
        vertical_line   480, 780, at: 523  ## 480 increase from bottom, 780 increase/decrease from top ### FOR RIGHT SIDE
        horizontal_line 0, 523, at: 780      
    end
 end



  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
    
    image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
        data1 = ([
           [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\n"+@compDetail.cmp_typeofbussiness.to_s+"\n"+@compDetail.cmp_addressline2.to_s+"\n"+@compDetail.cmp_addressline3.to_s, :inline_format=> true , :size => 10}],
        ])

        move_down 20        
  table([] + data1,:width =>523)  do
    style row(0), :align=>:left, :border_width => 0
    style column(0), :width     => 60
    style column(2), :width     => 100
    
  end

  move_down 10
  myrequest = ""
  if @Receipt.vd_requestfor.to_s == 'Loan'
      myrequest = "Advance"
  elsif @Receipt.vd_requestfor.to_s == 'Advance'
      myrequest = "MA Advance"
  else
    myrequest = @Receipt.vd_requestfor
  end
  startsession = ""
  spldated     = @Receipt.vd_voucherdate.to_s.split("-")
    if spldated && spldated[1].to_i >= 4
      startsession = spldated[0].to_s+"-"+(spldated[0].to_i+1).to_s
    else
      startsession = (spldated[0].to_i-1).to_s+"-"+spldated[0].to_s
    end
     text "<b>HUMAN RESOURCE DEVELOPMENT</b>",:align=>:center, :inline_format=> true
     if @Receipt.vd_requestfor.to_s == 'Education' || @Receipt.vd_requestfor.to_s == 'Marriage'
            data2 = ([
              [{:content =>"<u><b>SANCTION NOTE</b></u>", :inline_format=> true, :colspan => 4, :size => 10, :align => :center}],
              [{:content =>"<b>Sanction No. : </b>", :inline_format=> true}, {:content =>@Receipt.vd_voucherno.to_s}, {:content =>"<b>Sanction Date : </b>", :inline_format=> true},  {:content =>formatted_date(@Receipt.vd_voucherdate).to_s}],
              [{:content =>"<b>Sanction For : </b> ",:inline_format=> true},{:content =>myrequest.to_s+" Aid"},{:content =>"<b>Financial Year : </b>",:inline_format=> true},{:content =>startsession.to_s}],
            ])
      else
          data2 = ([
            [{:content => "<u><b>RECEIPT</b></u>", :inline_format=> true, :colspan => 4, :size => 10, :align => :center}],
            [{:content =>"<b>Receipt No. : </b>", :inline_format=> true}, {:content =>@Receipt.vd_voucherno.to_s}, {:content =>"<b>Receipt Date : </b>", :inline_format=> true},  {:content =>formatted_date(@Receipt.vd_voucherdate).to_s}],
            [{:content =>"<b>Receipt for : </b> ",:inline_format=> true},{:content =>myrequest.to_s},{:content =>"<b>Remarks : </b>",:inline_format=> true},{:content =>@Receipt.vd_remark.to_s+"\n Request No-"+@Receipt.vd_requestno.to_s+"\n Dated "+formatted_date(@Receipt.vd_requestdate).to_s}],
          ])

      end
      table([] + data2,:width =>523)  do
          style row(1..3),:size => 10, :align=>:left
          style row(1..2).column(0), :width =>100
          style row(1..2).column(1), :width =>40
          style row(1..2).column(2), :width =>130
          style row(1..2).column(3), :width =>103
          style row(1..2).column(4), :width =>20
          style row(1..2).column(5), :width =>130
          style row(0..2), :border_width => 1          
          row(0).column(0).background_color = 'DCDCDC'
        end
        types = ""
        if @Receipt.vd_requestfor.to_s == 'Education' || @Receipt.vd_requestfor.to_s == 'Marriage'
          types = @Receipt.vd_requestfor.to_s+" Aid"
        else
          if @Receipt.vd_requestfor.to_s == 'Loan'
            types = "Advance"
        elsif @Receipt.vd_requestfor.to_s == 'Advance'
            types = "MA Advance"
          else
            types = @Receipt.vd_requestfor
          end
        end
move_down 5
        text  "#{Prawn::Text::NBSP*1} <b>Reference No. : </b>SNM/HRD/"+@Receipt.vd_sewadarcode.to_s+"/"+types.to_s.upcase+"/"+startsession.to_s+"/"+@Receipt.vd_voucherno.to_s,:inline_format=> true,:size => 10

  move_down 10
  mycoldecode = ""
  if @Receipt.sewoldcode != nil && @Receipt.sewoldcode !=''
     mycoldecode  = " ("+@Receipt.sewoldcode.to_s+"/"+@Receipt.vd_sewadarcode.to_s+")"
  else
    mycoldecode  = " ("+@Receipt.vd_sewadarcode.to_s+")"  
  end

if myrequest.to_s == 'Education' || myrequest.to_s == 'Marriage'
  data3 = ([
    [{:content =>"Sanction, is hereby accorded to the grant of  "+"<b>"+myrequest.to_s.upcase+" AID of Rs. "+currency_formatted(@Receipt.vd_reqamount).to_s+" (Rupees "+number_currency_in_words+") </b>to "+"<u>"+@Receipt.sewadar_name.to_s+mycoldecode.to_s+", "+@Receipt.department.to_s+"</u>.", :inline_format=> true , :colspan => 5}],
    [{:content =>"", :inline_format=> true , :colspan => 5, :align => :center}],
  
    ])
  
else
    data3 = ([
    [{:content =>"Sanction, is hereby, accorded to the grant of advance of Maintenance Allowance of Rs. "+"<u>"+currency_formatted(@Receipt.vd_reqamount).to_s+"/</u>-"+" ( Rupees "+"<b><u>"+number_currency_in_words+"</u></b> only )"+" "+"<u>"+@Receipt.sewadar_name.to_s+" ("+@Receipt.vd_sewadarcode.to_s+") , "+@Receipt.department.to_s+"</u>\n"+"The advance is recoverable in installments of Rs "+currency_formatted(@Receipt.al_installpermonth).to_s+" per month. The last installment will be of Rs. "+currency_formatted(@Receipt.al_installpermonth).to_s+" ", :inline_format=> true , :colspan => 5}],
    [{:content =>"Passed for Payment", :inline_format=> true , :colspan => 5, :align => :center}],

    ])

end
table([] + data3,:width =>523)  do
style row(0),  :size => 10, :align=>:left
style row(1).column(0), :width =>30
style row(1).column(1), :width =>363
row(1).column(2).font_style = :bold
row(3).font_style = :bold
style row(0..3), :border_width => 0

end

mydependents = ""
if @Receipt.dependentname !=nil && @Receipt.dependentname !=''
  mydependents = "-("+@Receipt.dependentname.to_s+")"
end
move_down 20
data4 = ([ [{:content=>" <b>Remarks :</b>",:inline_format=>:true},{:content=>"Request No-"+@Receipt.vd_requestno.to_s+" Dated "+formatted_date(@Receipt.vd_requestdate).to_s+mydependents.to_s+" "+@Receipt.vd_remark.to_s,:size => 10}]      ])
table([] + data4,:width =>523)  do
  style row(0),  :size => 10, :align=>:left, :border_width=> 0
  style row(0).column(0), :width =>60, :align=>:left, :border_width=> 0
  style row(0).column(1), :width =>463, :align=>:left, :border_width=> 0
  # row(1).column(2).font_style = :bold
  # row(3).font_style = :bold
  # style row(0..3), :border_width => 0
  
  end



move_down 20
data5 = ([
  [{:content =>"Generated by \n"+@username.to_s.upcase+" "+(@myusercode !=nil && @myusercode !='' ? "" : '').to_s, :inline_format=>true , :colspan => 2},{:content =>"Signature\nMember Incharge",:colspan => 2}],
])

table([] + data5,:width =>523)  do
  style row(0).column(0..1),  :size => 10, :align=>:center, :border_width => 1, :font_style => :bold
  style row(0).column(2..3),  :size => 10, :align=>:center, :border_width => 1, :font_style => :bold
  style row(0).column(4),  :size => 10, :align=>:center, :border_width => 1, :font_style => :bold
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