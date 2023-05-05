# To change this template, choose Tools | Templates
# and open the template in the editor.

class LicPdf < Prawn::Document
  def initialize(seawdarsobj,compdetail,uRl,sewadarpersonal,empchecked,empkyc,empkycbank,empqualif,familydetail,empworkexp,empstatelist,empdistrict,hodlisted,empdepartment)
    super(:top_margin=>5,:page_size =>"A4" )
    @seawdarsobj          = seawdarsobj
    @compDetail           = compdetail
    @sewadarpersonal      = sewadarpersonal
    @empChecked           = empchecked
    @empkyc               = empkyc
    @empkycbank           = empkycbank
    @EmpKycQulifc         = empqualif
    @EmpKycFamily         = familydetail
    @EmpWorkExp           = empworkexp
    @EmpStatelist         = empstatelist
    @EmpDistrict          = empdistrict
    @Hodlisted            = hodlisted
    @EmpDepartment        = empdepartment
    @uRl2                 = uRl
    @uRl                  = Rails.root.join "public"
    @logoSize             = 0.5 
    @CheckSize            = 0.015
    line_items
    
 end


 
 
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items
     ps = 1
       #if @salary && @salary.length >0
         #@salary.each do |newsalry|
        #  move_down 30
        # image_path = {:image=>open(@uRl.to_s+"/assets/img/newlogo.png"), :scale => @logoSize}
        # data1 = ([
        #    [image_path,{:content => "<b>"+@compDetail.cmp_companyname.to_s+"</b>", :inline_format=> true , :size => 15}, 
        #     {:content =>" "}, 
        #     {:content => "<b>""DR. PARVEEN KHULLAR""</b>"+"\nMember Incharge""\n"+"Contact No : 9266629833 \n9999999999""\n"+"Email: hrd@nirankari.org"+"\n""Web: www.nirankari.org", :inline_format=> true , :size => 10} ],
        # ])


  # table([] + data1,:width =>528)  do
  #   style row(0),  :border_width => 0
  #   style column(0), :width     => 60, :align=>:left, :text_color => "346842"
  #   style column(1), :width => 100
  #   style column(2), :width     => 220, :size => 9,  :text_color => "346842"
  #   #cells.padding = 3
  #   #style row(2),  :size => 12,:align=>:center, :border_width => 0
  #   #style row(0..6).column(0), :width     => 528
  #   #row(2).font_style = :bold
  #   #self.row_colors =["FFFFFF"]
  #   #self.header =true
  #   #row(0).column(0).background_color = 'DCDCDC'
  # end
  move_down 10

  data230 =([
    [{:content => "NO DUES CHECKLIST"}]
  ])
  table([] + data230, :width => 528) do

    style row(0), :align => :center, :font_style => :bold, :size => 15, :border_width => 0, :width => 528
  end

   move_down 10
   data210 = ([

    [{:content => "Sewadar's Name "},
    {:content => ":"},
    {:content => " "},
    {:content => "Date of relieving"},
    {:content => ":"},
    {:content => " "},],

  ])

table([] + data210, :width => 528) do
  style row(0..1), :border_width => 0 , :size => 12 , :align => :left, :border_width => 0
  style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
  style row(0).column(0), :width =>132
  style row(0).column(1),:width => 44
  style row(0).column(2),:width =>88
  style row(0).column(3),:width =>132
  style row(0).column(4),:width => 44
  style row(0).column(5),:width =>88
end
move_down 10
data210 = ([

 [{:content => "Sewadar's Code"},
 {:content => ":"},
 {:content => " "},
 {:content => " "},
 {:content => " "},
 {:content => " "},],

])

table([] + data210, :width => 528) do
style row(0..1), :border_width => 0 , :size => 12 , :align => :left, :border_width => 0
style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
style row(0).column(0), :width =>132
style row(0).column(1),:width => 44
style row(0).column(2),:width =>88
style row(0).column(3),:width =>132
style row(0).column(4),:width => 44
style row(0).column(5),:width =>88
end
move_down 10
data211 = ([

  [{:content => "Department Name"},
  {:content => ":"},
  {:content => " "},
  {:content => "Reason for leaving"},
  {:content => ":"},
  {:content => " "},],

])

table([] + data211, :width => 528) do
  style row(0..1), :border_width => 0 , :size => 12 , :align => :left, :border_width => 0
  style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
  style row(0).column(0), :width =>132
  style row(0).column(1),:width => 44
  style row(0).column(2),:width =>88
  style row(0).column(3),:width =>132
  style row(0).column(4),:width => 44
  style row(0).column(5),:width =>88
end


   
#   data21 = ([

#     [{:content => ""},
#     {:content => "Calculation of Ex-gratia payment of Sewadar"},
#     {:content => ""}]

#   ])

# table([] + data21, :width => 522) do
#   style row(0), :border_width => 0 , :size => 12 , :align => :center
#   style row(0).column(1), :font_style => :bold
# end
move_down 20

checkbox = {:image=>open(@uRl.to_s+"/assets/img/checkbox.png"), :scale => @CheckSize }

my_table = make_table([["Telephone                               "], ["SIM card",checkbox], ["Telephone",checkbox], ["Dongle",checkbox] ], :cell_style => {:border_width => 0})
my_table2 = make_table([["Computers and Internet          "], ["Computer",checkbox], ["Laptop",checkbox]],:cell_style => {:border_width => 0})
my_table3 = make_table([["Human Resource Department"], ["Access Card",checkbox], ["Identity Card",checkbox], ["Keys of Drawers/ Almirah",checkbox] ],:cell_style => {:border_width => 0})
my_table4 = make_table([["Others"], [" "], [" "], [" "] ],:cell_style => {:border_width => 0})
my_table5 = make_table([["Department attached to"], [" "] ],:cell_style => {:border_width => 0})
my_table6 = make_table([["Accounts (Except Advance)"], [" "] ],:cell_style => {:border_width => 0})



data22 = ([
  [{:content => "Departments/ items"},
   {:content => "Date of return"},
   {:content => "Signature of the receiving authority"}],
  [{:content => my_table5},
   {:content => " "},
   {:content => " "}],
  [{:content => my_table6},
   {:content => " "},
   {:content => " "}],
  [{:content => my_table},
   {:content => " "},
   {:content => " "}],
  [{:content => my_table2},
   {:content => " "},
   {:content => " "}],  
   [{:content => my_table3},
    {:content => " "},
    {:content => " "}],
    [{:content => my_table4},
      {:content => " "},
      {:content => " "}],

])

table([] + data22, :width => 528)do


style row(0), :font_style => :bold
style row(0..4).column(0), :width     => 200 , :align=>:left, :size => 12
style row(0..4).column(1), :width => 152, :size => 12
style row(0..4).column(2), :width     => 176, :size => 12
# style row(5).column(0), :width => 50, :align=>:left, :size => 12
# style row(5).column(1), :width => 277, :align=>:left, :size => 12
# style row(5).column(2), :width => 67, :align=>:left, :size => 12
# style row(5).column(3), :width => 67, :align=>:left, :size => 12
# style row(5).column(4), :width => 67, :align=>:left, :size => 12

end


move_down 20
    data225 = ([
      
      [{:content => " Manager\n Human Resource Department"}],
     
    
    ])
    
    table([] + data225, :width => 528)do
    style row(0..5),  :border_width => 0, :font_style => :bold
    style row(0..4).column(0), :width     => 528, :align=>:left, :size => 12


    # style row(5).column(0), :width => 50, :align=>:left, :size => 12
    # style row(5).column(1), :width => 277, :align=>:left, :size => 12
    # style row(5).column(2), :width => 67, :align=>:left, :size => 12
    # style row(5).column(3), :width => 67, :align=>:left, :size => 12
    # style row(5).column(4), :width => 67, :align=>:left, :size => 12
    
    end
    
move_down 15
data225 = ([
  

   [{:content => "Member-in-Charge\nHuman Resources Department "}],

])

table([] + data225, :width => 528)do
style row(0..5),  :border_width => 0, :font_style => :bold
style row(0..4).column(0), :width     => 528, :align=>:left, :size => 12


# style row(5).column(0), :width => 50, :align=>:left, :size => 12
# style row(5).column(1), :width => 277, :align=>:left, :size => 12
# style row(5).column(2), :width => 67, :align=>:left, :size => 12
# style row(5).column(3), :width => 67, :align=>:left, :size => 12
# style row(5).column(4), :width => 67, :align=>:left, :size => 12

end
move_down 50

  move_down 100
  if ps.to_i%2 == 0
     move_down 60
  end
  ps +=1
  
  
    # end ## end    for
   #end  ## if

    
   
   
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