# To change this template, choose Tools | Templates
# and open the template in the editor.

class CardlistPdf < Prawn::Document
  def initialize(invoice,compDetail,heads,uRl,rssess)
    super(:top_margin=>5,:page_size =>"A4" )
    @invoice    = invoice   
    @compDetail = compDetail
    @mycattype  = heads
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5 
	@logoSize1  = 0.21
	@membcateg  = rssess[:swp_sewa_member]
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
                       
         
          move_down 10
          text "<b><u>Sewadar Card List</u></b>", :align => :center, :size =>10,:font_weight=>:bold,:inline_format=> TRUE
			if @mycattype && @mycattype == 'SW'
			      if @invoice && @invoice.length >0
					text " Category : "+(@invoice!=nil && @invoice[0].sw_catgeory != nil && @invoice[0].sw_catgeory !=''  ? @invoice[0].sw_catgeory : '' ).to_s+"", :align => :center, :size =>9,:font_weight=>:bold,:inline_format=> TRUE
				end
			else
			text " Category : "+@membcateg.to_s+"", :align => :center, :size =>9,:font_weight=>:bold,:inline_format=> TRUE
			end
          Time.zone = "Kolkata"         
        

   end

    move_down 15
   
      table line_item_rows, :cell_style=>{:inline_format=> TRUE}, :width=>540 do
      row(0).column(1..5).align        = :center      
      row(0..5000).column(0).width     = 30	   
      cells.size                       = 7
      cells.padding                    = 1
      cells.min_width                  = 150
      cells.border_width               = 1
      row(0).column(0..5).border_width = 1
      self.row_colors =["FFFFFF"]
      row(0).column(0..15).background_color    = 'D3D3D3'
      row(0).column(0..15).text_color          = '000080'
      self.header =true
    end  
    
   
   
  end
          

 def line_item_rows   
	root_url = @uRl2
    [["SlNo.","Image","Code","Name","Department"]]+
    @invoice.each.map do |inv|
			myimages = "#{root_url}assets/img/profiles/avatar-02.jpg"
			if inv.sw_image !=nil && inv.sw_image !=''
					if @mycattype == 'SW'
						chekpath = "#{Rails.root}/public/images/sewadar/"+inv.sw_image.to_s
						if File.file?(chekpath)
							myimages = "#{root_url}images/sewadar/"+inv.sw_image.to_s
						end
					elsif 	@mycattype == 'MB'
						chekpath = "#{Rails.root}/public/images/ledger/profile/"+inv.sw_image.to_s
						if File.file?(chekpath)
							myimages = "#{root_url}images/ledger/profile/"+inv.sw_image.to_s
						end
					end

			  end
       [count,{:image=>open(myimages.to_s),:position =>:center,:scale => @logoSize1},inv.sw_sewcode.to_s,inv.sw_sewadar_name,inv.department]
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