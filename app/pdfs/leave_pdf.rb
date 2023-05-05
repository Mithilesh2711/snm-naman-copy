# To change this template, choose Tools | Templates
# and open the template in the editor.

class LeavePdf < Prawn::Document
  def initialize(department,compdetail)
    super(:margin_top=>30,:page_size =>[700, 700], :page_layout => :landscape)
    @department = department
    @compdetail = compdetail
    leave_items
    line_items
  end
  def leave_items
    if @compdetail
      if @compdetail.cmp_companyname!='' && @compdetail.cmp_companyname!=nil
        text @compdetail.cmp_companyname.to_s, :align => :left, :size =>11,:font_weight=>:bold,:inline_format=> TRUE
      end
      if @compdetail.cmp_addressline1!='' && @compdetail.cmp_addressline1!=nil
        text @compdetail.cmp_addressline1.to_s, :align => :left, :size =>8,:font_weight=>:bold,:inline_format=> TRUE
      end
      if @compdetail.cmp_addressline2!='' && @compdetail.cmp_addressline2!=nil
        text @compdetail.cmp_addressline2.to_s, :align => :left, :size =>8,:font_weight=>:bold,:inline_format=> TRUE
      end
      if @compdetail.cmp_addressline3!='' && @compdetail.cmp_addressline3!=nil
        text @compdetail.cmp_addressline3.to_s, :align => :left, :size =>8,:font_weight=>:bold,:inline_format=> TRUE
      end     
    end
    
  end
  def line_items
     move_down 20
     table line_item_rows,  :width=>650 do
      #row(0).font_style = :bold
      column(1..18).align = :center
      cells.size = 7
      cells.padding = 5
      #cells.min_width = 523
      cells.border_width = 1
      #self.row_colors =["DDDDDD","FFFFFF"]
      self.header =true      
    end
  end
  def line_item_rows
    [["Leave Code","Leave Type","Paid Leave","Bal Leave","Working","Encash","Bal. Prev. CF","Annual Quota","Accum. Leave"]]+
    @department.map do | depart |
    [depart.attend_leaveCode.to_s,depart.attend_leavetype.to_s,depart.attend_paidleave.to_s,depart.attend_balancesleave.to_s,depart.attend_runworking.to_s,depart.attend_enchash.to_s,depart.attend_balanceforprevious.to_s,depart.attend_annualquota.to_s,depart.attend_accumulationleave.to_s]
    end
  end
end
