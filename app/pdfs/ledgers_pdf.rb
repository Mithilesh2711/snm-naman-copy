# To change this template, choose Tools | Templates
# and open the template in the editor.

class LedgersPdf < Prawn::Document
  def initialize(report,compDetail,uRl,opbal,gprams,sewdar,sewacode,desiname,department,leavecodes,leavename,category)
    super(:margin_top=>20,:page_size =>"A4",:background => "public/assets/img/HRD1.jpeg")
    @invoice    = report    
    @compDetail = compDetail    
    @uRl2       = uRl
    @uRl        = Rails.root.join "public"
    @logoSize   = 0.5    
    @from_date  = gprams[:leave_fromdated].to_s
    @upto_date  = gprams[:leave_uptodated].to_s  
    @opbal      = opbal
    @sewdarname = sewdar
    @sewacode   = sewacode
    @desiname   = desiname
    @department = department
    @leavecodes = leavecodes
    @leavename  = leavename
    @category   = category
     line_items
 end

  def terms_and_conditions
       "Terms and Conditions"
  end
  def count_mcell
  @count_cell ||= 0
  @count_cell = @count_cell+1
end
  def line_items

        move_down 2
          pad(-1) {
           if @compDetail.cmp_show_logo =='Y'
              if @compDetail.cmp_logos.to_s.length >1
                npath = Rails.root.join "public",'images','logo','thumb'
               if File.exists?("#{npath}/"+@compDetail.cmp_logos.to_s)
                 image open(@uRl+"images/logo/thumb/"+@compDetail.cmp_logos.to_s),:scale => @logoSize,:position => :right,:vposition => :top
               end
              end
           end 
          }
          # header
          nfrdats =''
          bounding_box [bounds.left, bounds.top], :width  => bounds.width do
          font "Helvetica"
          if @show_add!=nil && @show_add!='' && @show_add =='Y'
              if @compDetail.cmp_companyname.to_s!=nil && @compDetail.cmp_companyname.to_s!=''
              text @compDetail.cmp_companyname.to_s.upcase, :align => :left, :size => 10,:vposition => :top
              end
              if @compDetail.cmp_addressline1.to_s!=nil && @compDetail.cmp_addressline1.to_s!=''
              text ((@compDetail.cmp_addressline1.to_s.length.to_i >1) ? @compDetail.cmp_addressline1.to_s.capitalize: '' )+((@compDetail.cmp_addressline2.to_s.length.to_i >1) ? ((@compDetail.cmp_addressline1.to_s.length.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline2.to_s.capitalize : '')+((@compDetail.cmp_addressline3.to_s.length.to_i >1) ? ((@compDetail.cmp_addressline2.to_s.length.to_i >1) ? ', ': '' )+@compDetail.cmp_addressline3.to_s.capitalize: ''), :align => :left, :size => 9,:vposition => :top
              end
              if @compDetail.cmp_telephonenumber.to_s!=nil && @compDetail.cmp_telephonenumber.to_s!=''
              text @compDetail.cmp_telephonenumber.to_s+((@compDetail.cmp_telephonenumber.to_s.length.to_i >1) ? ', +91 ': '')+@compDetail.cmp_cell_number.to_s, :align => :left, :size =>9,:vposition => :top
              end
          end
          if @from_date!='' && @from_date!=nil
            frdats  = Date.parse(@from_date.to_s)
            nfrdats = frdats.strftime('%d-%b-%Y')
          end
          if @upto_date!='' && @upto_date!=nil
            utdats  = Date.parse(@upto_date.to_s)
            nutdats = utdats.strftime('%d-%b-%Y')
          end
          ltnewdats = ''
          if @lastPmtDate!=nil && @lastPmtDate!=''
            ltdats    = Date.parse(@lastPmtDate.to_s)
            ltnewdats = ltdats.strftime('%d-%b-%Y')
          end

          move_down 150

           text "<b>Ledger Register</b>", :align => :center, :size =>14,:inline_format=> TRUE

           move_down 5
          if @from_date !=nil && @from_date !='' && @upto_date !='' && @upto_date !=nil
            text "<b>From Date : "+nfrdats.to_s+" Upto Date : "+nutdats.to_s+"</b>", :align => :center, :size =>11,:inline_format=> TRUE
          end

          move_down 20
          data211 = ([

            [{:content => "Sewadar Code"},
            {:content => ":"},
            {:content => @sewacode.to_s},
            {:content => "Sewadar Name"},
            {:content => ":"},
            {:content => @sewdarname.to_s},],
          
          ])
          
          table([] + data211, :width => 528) do
            style row(0..1), :border_width => 0 , :size => 9 , :align => :left, :border_width => 0
            style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
            style row(0).column(0), :width =>92
            style row(0).column(1),:width => 24
            style row(0).column(2),:width =>148
            style row(0).column(3),:width =>92
            style row(0).column(4),:width => 24
            style row(0).column(5),:width =>148
          end
          

          functiondept = ''
            if @department != nil && @department !=''
              functiondept = "Department"
            else
               @desiname != nil && @desiname !=''
              functiondept = "Designation"
            end
            functionvalue = ''
            if @department != nil && @department !=''
              functionvalue = @department.to_s
            else
             @desiname != nil && @desiname !=''
             functionvalue = @desiname.to_s
            end
            functioncategory = ""
                 if @category != nil && @category != ''
                  functioncategory = "Category"
                 end
            functcatvalue = ""
            if @category != nil && @category != ''
              functcatvalue =  @category.to_s
             end

          data212 = ([

            [{:content => functioncategory},
            {:content => ":"},
            {:content =>functcatvalue},
            {:content => functiondept},
            {:content => ":"},
            {:content => functionvalue},],
          
          ])
          
          table([] + data212, :width => 528) do
            style row(0..1), :border_width => 0 , :size => 9 , :align => :left, :border_width => 0
            style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
            style row(0).column(0), :width =>92
            style row(0).column(1),:width => 24
            style row(0).column(2),:width =>148
            style row(0).column(3),:width =>92
            style row(0).column(4),:width => 24
            style row(0).column(5),:width =>148
          end
         
          data213 = ([

            [{:content => "Leave Type"},
            {:content => ":"},
            {:content =>@invoice ? @invoice[0].leavecode : ''},
            {:content => ""},
            {:content => ""},
            {:content => ""},],
          
          ])
          
          table([] + data213, :width => 528) do
            style row(0..1), :border_width => 0 , :size => 9 , :align => :left, :border_width => 0
            style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
            style row(0).column(0), :width =>92
            style row(0).column(1),:width => 24
            style row(0).column(2),:width =>148
            style row(0).column(3),:width =>92
            style row(0).column(4),:width => 24
            style row(0).column(5),:width =>148
          end
          # functionleave = ''
          #     if @leavename != nil && @leavename !=''
          #       functionleave =  "Leave Type"
          #     end
          # functLeaveValue = ''
          #     if @leavename != nil && @leavename !=''
          #       functLeaveValue =  @sewdarname.to_s
          #     end

          # data212 = ([

          #   [{:content => functionleave},
          #   {:content => ":"},
          #   {:content => functLeaveValue},
          #   {:content => ""},
          #   {:content => ""},
          #   {:content => " "},],
          
          # ])
          
          # table([] + data212, :width => 528) do
          #   style row(0..1), :border_width => 0 , :size => 9 , :align => :left, :border_width => 0
          #   style row(0..1).column(1), :font_style => :bold, :width => 20, :border_width => 0
          #   style row(0).column(0), :width =>92
          #   style row(0).column(1),:width => 24
          #   style row(0).column(2),:width =>148
          #   style row(0).column(3),:width =>92
          #   style row(0).column(4),:width => 24
          #   style row(0).column(5),:width =>148
          # end
      #     text "Sewadar Code : <b>"+@sewacode.to_s+"</b>", :align => :center, :size =>8,:inline_format=> TRUE
      #     text "Sewadar Name : <b>"+@sewdarname.to_s+"</b>", :align => :center, :size =>8,:inline_format=> TRUE
     
  
      #     if @leavename != nil && @leavename !=''
      #        text "Leave Type  : <b>"+@sewdarname.to_s+"</b>", :align => :center, :size =>8,:inline_format=> TRUE
      #     end




           
       end


      move_down 20
      lngth =  @invoice.length
      text "Opening Bal. : "+ ( "%.2f" % @opbal.to_f ).to_s.delete('-'), :align => :right, :size =>10
      if @invoice.length >0
          
              table line_item_rows,  :width=>525 do
              row(0).column(1..7).align = :center
              row(0).column(1).width=30
              row(0).column(2).width=20
              row(0).column(4).width=60
              row(0).column(6).width=30              
              row(1..5000).column(1..4).align = :center
              row(1..5000).column(5..7).align = :right
              #row(lngth..5000).font_style =:bold
              cells.size = 10
              cells.padding = 5
              cells.min_width = 300
              cells.border_width = 1
              self.row_colors =["FFFFFF"]
              self.header =true
            end
        #end
    end
    nclosigbalance = @clbal.to_s.delete("-")
    if nclosigbalance.to_f <=0
      @clbal =  @opbal.to_f
    end
    move_down 4
    text " "
  
         


  
    text "Closing Bal. : "+ ( "%.2f" % @clbal.to_f).to_s, :align => :right, :size =>10 
    
    
 end



 def line_item_rows
     obs = @opbal
	 balances    = obs
     [["Sl.No.","Date","Credit","Taken","Balance"]]+
      @invoice.each.map do |inv|
	     creiditedlv = 0
		 debitedleve = 0
		 
		 if inv.mytpe == 'dbt'
		    balances = balances.to_f-inv.tleave.to_f
			debitedleve = inv.tleave.to_f
		 elsif inv.mytpe == 'cdt'
			balances = balances.to_f+inv.tleave.to_f
			creiditedlv = inv.tleave.to_f
		 end
     ptypes = ""
     if inv.periodtype.to_s.upcase == 'S'
      ptypes +=" (Second Half)"
    elsif inv.periodtype.to_s.upcase == 'F'  
      ptypes +=" (First Half)"
     end
		 @clbal = balances
        [count,date_formats(inv.datefirst).to_s+" To "+date_formats(inv.datesecond).to_s+" ("+inv.transactno.to_s+" )",creiditedlv.to_s,debitedleve.to_s+ptypes.to_s,balances.to_s]
      end
 

end

def count
  @count ||= 0
  @count = @count+1
end
def make_sum_of_all
    @tqnty    = 0
    @tdsamt   = 0
    @tigstamt = 0
    @tcgstamt = 0
    @tsgstamt = 0
    @tnetamt  = 0
    @dtvalues = 0
    @invoice.each do |ts|
        @tqnty    = @tqnty+ts.dt_quantity
        @tdsamt   = @tdsamt+ts.dt_discountamount
        @tigstamt = @tigstamt+ts.dt_igstamount
        @tcgstamt = @tcgstamt+ts.dt_cgstamount
        @tsgstamt = @tsgstamt+ts.dt_sgstamount
        @tnetamt  = @tnetamt+ts.dt_netamount
        @dtvalues = @dtvalues+ts.dt_values
   end
 end
 def number_currency_in_words
   NumbersInWords.in_words(@tnetamt.to_f).split(/ |\_|\-/).map(&:capitalize).join(" ")
 end
def date_formats(dates)
  if dates.to_s!=nil && dates.to_s!=''
    nrdate = Date.parse(dates.to_s)
    ndate  = nrdate.strftime('%d-%b-%Y')
  end
end
end
