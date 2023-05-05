# To change this template, choose Tools | Templates
# and open the template in the editor.

class ApproveeducationPdf < Prawn::Document
  def initialize(invoice,compDetail,heads,uRl,incharg)
    super(:top_margin=>5,:page_size =>"A4")
    @invoice    = invoice   
    @compDetail = compDetail
    @heads      = heads
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5   
    line_items
    
 end

 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
          move_down 1         
          # header
          bounding_box [bounds.left, bounds.top], :width  => bounds.width do
          font "Helvetica"          
          if @storedt && @storedt.lc_logo.to_s.length >1
             @filesExt = Rails.root.join "public", "images", "storelogo",@storedt.lc_logo.to_s
             if File.exist?(@filesExt)
              image open(@uRl+"images/storelogo/"+@storedt.lc_logo.to_s),:scale => @logoSize,:position => :center,:vposition => :top
             else
               pad(5) { text "" }
             end
          end
                        
                       
                       image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
                       data1 = ([
                          [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>"+"\nAddress: "+@compDetail.cmp_addressline1.to_s+"\n"+@compDetail.cmp_addressline2.to_s+"\n"+@compDetail.cmp_addressline3.to_s+"", :inline_format=> true , :size => 10}],
                       ])
               
               
                 table([] + data1,:width =>528)  do
                   style row(0), :align=>:left, :border_width => 0
                   style column(0), :width     => 60
                   style column(2), :width     => 100
                   
                 end
                 move_down 10
        text "<b><u>Education Aid List</u></b>" , :inline_format=> :true, :align=> :center
        data4 = ([
                [{:content =>"S No."},{:content =>"Request No\nRequest Date\nApply For"},{:content =>"Sewdar Details"}, {:content =>"Aadhaar No\nDate of Birth"}, {:content => "Dependent\nFor Class\nAmount\nSchool/University"}, {:content =>"Remark"}, {:content =>"Forwarded By (Sh./Smt.)"}],
                      
                ])
          if @invoice.length >0
          @invoice.each.map do |inv|
              newrefrcode = ""
              selfadhar = ""
              selfdob   = ""
              if inv.refercode !=nil && inv.refercode !=''
                newrefrcode = " ("+inv.refercode.to_s+")"
              end
              genders = ""
              if inv.sw_gender =='M'
                genders = "Male"
              elsif inv.sw_gender =='F'
                genders = "Female"      
              end
              
              if inv.aea_applyfor.to_s.downcase =='self' 
                  selfadhar = inv.selfadhar
                  selfdob   = inv.selfdob
              elsif inv.aea_applyfor.to_s.downcase =='dependent' 
                  selfadhar = inv.aadhaarno
                  selfdob   = inv.doblist
              end
           
            data4 += ([           
            [{:content =>count.to_s},{:content =>inv.aea_requestno.to_s+"\n"+formatted_date(inv.aea_requestdate).to_s+"\n"+inv.vd_requestfor.to_s.capitalize},{:content =>inv.aea_sewadarcode.to_s+newrefrcode.to_s+"\n"+inv.sewdarname.to_s+"\n"+genders.to_s+"\n"+inv.department.to_s+"\n"+inv.deginname.to_s}, {:content =>selfadhar.to_s+"\n"+formatted_date(selfdob).to_s}, {:content => inv.relatoinname.to_s+"\n"+inv.classname.to_s+"\n"+currency_formatted(inv.aea_amount).to_s+"\n"+inv.schoolunversity}, {:content =>inv.aea_remark.to_s}, {:content =>inv.approvedby.to_s}],  
              
              ])

          end
        end
          table([] + data4,:width =>528)  do
            style row(0),  :size => 9, :align=>:left
            style row(1..5000),  :size => 8, :align=>:left
            style row(0..1).column(0),   :width => 33
            style row(0..1).column(1),   :width => 60
            style row(0..1).column(2),   :width => 77 , :align => :left
            style row(0..1).column(3),   :width => 92, :align => :center
            style row(0..1).column(4),   :width => 80 , :align => :center
            style row(0..1).column(5),   :width => 70 , :align => :center
            style row(0..1).column(6),   :width => 60 , :align => :center
            style row(0..1).column(7),   :width => 55 , :align => :left
            style row(1), :align =>:left
            row(0).background_color = '87CEEB'            
            row(0).font_style = :bold
            
            end

            




          end
   
   

#     move_down 10
   
#       table line_item_rows, :cell_style=>{:inline_format=> TRUE}, :width=>540 do
#       row(0).column(1..5).align        = :center      
#       row(0..5000).column(0).width     = 30	   
#       cells.size                       = 8
#       cells.padding                    = 1
#       cells.min_width                  = 150
#       cells.border_width               = 1
#       row(0).column(0..5).border_width = 1
#       self.row_colors =["FFFFFF"]
#       row(0).column(0..15).background_color    = '87CEEB'
#       # row(0).column(0..15).text_color          = ''
#       self.header =true
#     end  
    
   
   
#   end
  

#  def line_item_rows   
#     [["SlNo.","Request No\nRequest Date\nApply For","Sewdar Details","Aadhaar No\nDate of Birth","Dependent\nFor Class\nAmount","Remark","Approved By"]]
  
 
    # @invoice.each.map do |inv|
    #   newrefrcode = ""
    #   if inv.refercode !=nil && inv.refercode !=''
    #     newrefrcode = " ("+inv.refercode.to_s+")"
    #   end
    #   genders = ""
    #   if inv.sw_gender =='M'
    #      genders = "Male"
    #   elsif inv.sw_gender =='F'
    #      genders = "Female"      
    #   end
    #   selfadhar = ""
    #   selfdob   = ""
    #   if inv.aea_applyfor.to_s =='self' 
    #     selfadhar = inv.selfadhar
    #     selfdob   = inv.selfdob
    #   else
    #     selfadhar = inv.aadhaarno
    #     selfdob   = inv.doblist
    #   end
    #    [count,inv.aea_requestno.to_s+"\n"+formatted_date(inv.aea_requestdate).to_s+"\n"+inv.vd_requestfor.to_s,inv.aea_sewadarcode.to_s+newrefrcode.to_s+"\n"+inv.sewdarname.to_s+"\n"+genders.to_s+"\n"+inv.department.to_s+"\n"+inv.deginname.to_s,inv.selfadhar.to_s+"\n"+formatted_date(inv.selfdob).to_s,inv.relatoinname.to_s+"\n"+inv.classname.to_s+"\n"+currency_formatted(inv.aea_amount).to_s,inv.aea_remark.to_s,inv.approvedby.to_s]
    # end
end

    # data4 = ([
    #   [{:content =>"S No."},{:content =>"Sewadar Details"},{:content =>"MA Amount"}, {:content =>"TDS Deduction"}, {:content =>"Other Deduction"}, {:content =>"NetPay"}],
      
    #   ])
    # table([] + data4,:width =>528)  do
    # style row(0),  :size => 10, :align=>:left
    # style row(1..5000),  :size => 10, :align=>:left
    # style row(0).column(0),   :width => 39
    # style row(0).column(1),   :width => 200
    # style row(0).column(2),   :width => 83, :align => :right
    # style row(0).column(3),   :width => 68 , :align => :right
    # style row(0).column(4),   :width => 65 , :align => :right
    # style row(0).column(5),   :width => 73 , :align => :right
    # row(0..1).background_color = '87CEEB'
    
    # row(0..1).font_style = :bold
    
    # end
    
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