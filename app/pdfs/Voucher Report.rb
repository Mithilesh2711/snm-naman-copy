require "prawn"
require_relative 'E:\Ruby\prawn-table-master\prawn-table-master\lib\prawn\table.rb'

# Implicit Block
Prawn::Document.generate('implicit.pdf') do
   
  image_path = "#{Prawn::DATADIR}/images/newlogo.png"
    data1 = ([
        [{:content => "<b>SANT NIRANKARI MANDAL</b>", :inline_format=> true , :colspan => 2, :size => 15}, {:content =>image_path, :inline_format=> true , :colspan => 2, :rowspan => 2, :size => 15, :align=>:right, :border_width => 0}],
        [{:content => "H.Q Nirankari Complex, Delhi - 110019", :inline_format=> true, :colspan => 2, :size => 10}],
        [{:content => "<u>RECEIPT</u>", :inline_format=> true, :colspan => 4, :size => 10}]
        
])


table([] + data1,:width =>528)  do
    style row(0..1).column(0),  :size => 12,:align=>:left, :border_width => 0
    style row(2),  :size => 12,:align=>:center, :border_width => 0
    #style row(0..6).column(0), :width     => 528
    row(2).font_style = :bold
    #self.row_colors =["FFFFFF"]
    #self.header =true
    #row(0).column(0).background_color = 'DCDCDC'
  end

  move_down 20
data2 = ([
    [{:content =>"Document No."}, {:content =>":"}, {:content =>"1001"}, {:content =>"Dated"}, {:content =>":"}, {:content =>"19th Nov, 2021"}],
    [{:content =>"Remarks", :inline_format=> true , :colspan => 6}],
])
table([] + data2,:cell_style => {:inline_format => true })  do
    style row(0..2),  :size => 10, :align=>:left
    style row(0..1).column(0), :width =>120
    style row(0..1).column(1), :width =>20
    style row(0..1).column(2), :width =>120
    style row(0..1).column(3), :width =>120
    style row(0..1).column(4), :width =>20
    style row(0..1).column(5), :width =>120
    style row(0..1), :border_width => 0
    row(0..1).column(0).font_style = :bold
    row(0..1).column(3).font_style = :bold
  end


  move_down 20
data3 = ([
  [{:content =>"RECEIVED with thanks from Sant Nirankari Mandal, Sant Nirankari Colony, Delhi - 9, a sum of ", :inline_format=> true , :colspan => 4}],
  [{:content =>"Rs."},{:content =>"<u>22,000/- </u>", :inline_format=> true},{:content =>"Rupees"},{:content =>"<u>Twenty Two Thousan Four Hundred Only</u>", :inline_format=> true}],
  [{:content =>"by cash on account of", :inline_format=>true , :colspan => 3},{:content =>"<u>SARANJEET SINGH</u>", :inline_format=> true , :colspan => 2}],
  [{:content =>"Passed for Payment", :inline_format=> true , :colspan => 4, :align => :center}],
  
  ])
table([] + data3,:width =>528)  do
style row(0),  :size => 12, :align=>:left
style row(1).column(0), :width =>30
style row(1).column(1), :width =>80
style row(1).column(2), :width =>55
style row(1).column(3), :width =>363
row(1).column(0).font_style = :bold
row(1).column(2).font_style = :bold
row(3).font_style = :bold
style row(0..3), :border_width => 0
end

move_down 50
data4 = ([
  [{:content =>"Created By", :inline_format=>true , :colspan => 2},{:content =>"Secretary/Member Incharge", :inline_format=> true , :colspan => 2},{:content =>"Recepient Sign"}],
])
table([] + data4,:width =>528)  do
style row(0),  :size => 12, :align=>:center, :border_width => 0, :font_style => :bold
#style row(0).column(0), :width =>30
#style row(0).column(1), :width =>75
#style row(0).column(2), :width =>75
#style row(0).column(3), :width =>343
end

move_down 100
data5 = ([
  [{:content =>"*This document is computer generated and does not require the signature"}],
])
table([] + data5,:width =>528)  do
style row(0),  :size => 10, :align=>:left, :border_width => 0, :font_style => :bold
end
end