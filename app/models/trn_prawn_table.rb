class TrnPrawnTable < ApplicationRecord


  private
  def self.to_sale_stores
    attributes1 = %w{TransactionNo TransactionDate TransactionType QtyCredit QtyDebit Balance}
    attributes3 = %w{docNumber docDate docTranctype qtyCredit qtyDebit docBalance}
    headers     = [$compDetail.cmp_companyname.to_s.upcase,"","","",""]
    headers2    = [$compDetail.cmp_addressline1.to_s+($compDetail.cmp_addressline2.to_s.length >1 ? ", "+$compDetail.cmp_addressline2.to_s : '').to_s+($compDetail.cmp_addressline3.to_s.length >1 ? ", "+$compDetail.cmp_addressline3.to_s : '' ).to_s,"",""]
    headers3    = [($loc ? $loc.lc_name.to_s.upcase : '').to_s,"","","",""]
    headers4    = [( $loc ? $loc.lc_address.to_s.upcase : '' ).to_s,"","","",""]
    headers5    = ["LEDGER ACCOUNT","","","",""]
    headers6    = ["From Date : "+formatted_dated($frmDate).to_s,"","Upto Date : "+formatted_dated($uptoDate).to_s,"",""]
    headers7    = ["","","","",""]
    headers8    = ["","Opening Balance : "+new_currency_formatted($openBaln).to_s,"","","",""]
    pitems   = []
    if all.length >0
        if $ArrLedger && $ArrLedger.length >0
            $ArrLedger.each do |ledgs|
              newtrans = ledgs.docNumber.to_s.split("-")
              ledgs.docNumber    = newtrans[1] ? ","+newtrans[1].to_s : ''
              ledgs.docTranctype = newtrans[0] ? newtrans[0] : ''
              pitems.push ledgs
            end
        end
     end       
     isselect = "'' as compcode,'' as docNumber,'' as docDate,'' as receiveFrom,'' as docTranctype"
     isselect += ", '' as docQty,'' as lessQty,'' as docBalance,'' as storename,'' as storetype ,'Total' as types,'' as qtyCredit,'' as qtyDebit "
     subobj   = TrnPrawnTable.select(isselect).all    
     if subobj.length >0
        subobj.each do |mysub|
          pitems.push mysub
        end
     end

    colosbal = 0   
    CSV.generate(:headers=> true) do |csv|
    csv << headers
    csv << headers2
    csv << headers3
    csv << headers4
    csv << headers5
    csv << headers6
    csv << headers7
    csv << attributes1
    csv << headers8
        pitems.each do |product|
           if product.types != 'Total'
                  csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                  colosbal  += product.docBalance.to_f
            else
                  if product.types == 'Total'
                        product.docNumber = 'Closing Balance'
                        product.docBalance     = "%.2f" % $closinBal.to_f
                      csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                  end
            end
        end
    end

end
    private
   def self.new_currency_formatted(amt)
        amts = ''
        if amt!=nil && amt!=''
          amts = "%.2f" % amt.to_f
        end
        return amts
   end

  private
 def self.formatted_dated(dates)
      newdate = ''
      if dates!=nil && dates!=''
           dts    = Date.parse(dates.to_s)
           newdate = dts.strftime("%d-%b-%Y")
      end
      return newdate
 end


 private
  def self.sale_registerd
    if $myadminlogedd
      if $storetype.to_s !='outlet'
          attributes1 = %w{BillNo BillDate Type BarCode Brand SKU Size Season Category MRP HSN  Discount% DiscountAmount Taxable GST% GSTAmount Quantity  Nett.Amount PayMode Cash Card DirectDeposit GiftCardNo/CreditNoteNo  GiftCardAmount/CreditNoAmount IssueCreditNoteValue PurchaseRate PurchaseAmount GrossProfit CreditNoteSeries ForfeitValue CCNO DDRemark}
          attributes3 = %w{billseries bldate returntype barcode pdbrand skucode sizes seasons category mrp hsn discounts discamount taxableval taxes taxamount qty netamount pmtmode cashamt cardamt mydeposit giftCrediNote myusecreditNote issuecreditnote purchrates purchaseamount grossprofit creditnoteseriesd newmyfeedvalue myccNo mydirectremark}

       else
          attributes1 = %w{BillNo BillDate Type BarCode Brand SKU Size Season Category MRP HSN  Discount% DiscountAmount Taxable GST% GSTAmount Quantity  Nett.Amount}
          attributes3 = %w{billseries bldate returntype barcode pdbrand skucode sizes seasons category mrp hsn discounts discamount taxableval taxes taxamount qty netamount}

       end
    else
      if $storetype.to_s !='outlet'
          attributes1 = %w{BillNo BillDate Type BarCode Brand SKU Size Season Category MRP HSN  Discount% DiscountAmount Taxable GST% GSTAmount Quantity  Nett.Amount PayMode Cash Card DirectDeposit GiftCardNo/CreditNoteNo  GiftCardAmount/CreditNoAmount IssueCreditNoteValue CreditNoteSeries ForfeitValue CCNO DDRemark}
          attributes3 = %w{billseries bldate returntype barcode pdbrand skucode sizes seasons category mrp hsn discounts discamount taxableval taxes taxamount qty netamount pmtmode cashamt cardamt mydeposit giftCrediNote myusecreditNote issuecreditnote creditnoteseriesd newmyfeedvalue  myccNo mydirectremark}

      else
          attributes1 = %w{BillNo BillDate Type BarCode Brand SKU Size Season Category MRP HSN  Discount% DiscountAmount Taxable GST% GSTAmount Quantity  Nett.Amount}
          attributes3 = %w{billseries bldate returntype barcode pdbrand skucode sizes seasons category mrp hsn discounts discamount taxableval taxes taxamount qty netamount}

      end
      
    end

  #  headers     = [$compDetail.cmp_companyname.to_s.upcase,"","","",""]
  #  headers2    = [$compDetail.cmp_addressline1.to_s+($compDetail.cmp_addressline2.to_s.length >1 ? ", "+$compDetail.cmp_addressline2.to_s : '').to_s+($compDetail.cmp_addressline3.to_s.length >1 ? ", "+$compDetail.cmp_addressline3.to_s : '' ).to_s,"",""]
  #  headers3    = [($loc ? $loc.lc_name.to_s.upcase : '').to_s,"","","",""]
  #  headers4    = [( $loc ? $loc.lc_address.to_s.upcase : '' ).to_s,"","","",""]
  
    headers5    = ["SALE REGISTER","","","",""]
    headers6    = ["From Date : "+formatted_dated($frmDate).to_s,"","Upto Date : "+formatted_dated($uptoDate).to_s,"",""]
    headers7    = ["","","","",""]
    headers8    = ["Location : "+$locations.to_s,"","","",""]
    pitems   = []
    newnumber = ''
    if all.length >0
        if $execlallsoldregister && $execlallsoldregister.length >0
              $execlallsoldregister.each do |ledgs|
                       if ledgs.paytypes == 'S'
                         ledgs.returntype = "Sale"
                       elsif ledgs.paytypes == 'GF'
                         ledgs.returntype = "Sale"
                       elsif ledgs.paytypes == 'E'
                         ledgs.returntype = "Exchange"
                       elsif ledgs.paytypes == 'R'
                         ledgs.returntype = "Return"
                       end
                       if ledgs.paytypes == 'R'
                         xpurchaseamount = ledgs.purchrates.to_f*ledgs.qty.to_f*(-1)
                         ledgs.purchaseamount = new_currency_formatted(xpurchaseamount)
                       else
                         xpurchaseamount      = ledgs.purchrates.to_f*ledgs.qty.to_f
                         ledgs.purchaseamount = new_currency_formatted(xpurchaseamount)
                       end
                       
                       if ledgs.exhtype == 'R'
                           if ledgs.billseries !='' && ledgs.billseries !=nil
                             billseries              = ledgs.billseries
                             nbilseries              = billseries.to_s.gsub("CN","EN")
                             blseries                = nbilseries.to_s.split("/")
                             newseriesd              = blseries[0].to_s+"/"+blseries[1].to_s+"/"+blseries[2].to_s+"/"+ledgs.billnumber.to_s
                             ledgs.creditnoteseriesd = ledgs.billseries
                             ledgs.billseries        = newseriesd
                             ledgs.issuecreditnote    = "%.2f" % ledgs.netamount.to_f
                          end
                       end
                       
                       ledgs.taxableval = ledgs.netamount.to_f-ledgs.taxamount.to_f
                       if  newnumber!=ledgs.billseries
                            ledgs.newmyfeedvalue = ledgs.exh_forfeedvalue
                           if ledgs.bstatus!='C'
                                     if ledgs.directdeposit =='Y'
                                       ledgs.mydeposit = ledgs.cardamt
                                       ledgs.cardamt    = 0
                                     end
                                     ledgs.cashamt     = ledgs.cashamt
                                     if ledgs.pmtmode =='C'
                                           ledgs.pmtmode ="Cash"
                                     elsif ledgs.pmtmode =='D'
                                           if ledgs.directdeposit =='Y'
                                              ledgs.pmtmode ="Direct Deposit"
                                           else
                                              ledgs.pmtmode ="Card"
                                           end
                                     elsif ledgs.pmtmode =='B'
                                           ledgs.pmtmode ="Cash & Card"
                                     end
                                     if ledgs.giftCrediNote.to_s.length >1
                                        if ledgs.promotype == 'CN'
                                               ledgs.myusecreditNote =  ledgs.giftCrediNote #ledgs.myusecreditNote
                                              # ledgs.CreditNoAmount  =  ledgs.giftCrediNote
                                               ledgs.giftCrediNote    = "Credit Note"

                                        elsif ledgs.promotype == 'GC'
                                            ledgs.myusecreditNote =  ledgs.myusecreditNote
                                            ledgs.giftCrediNote = "Gift Card"
                                        else
                                            ledgs.giftCrediNote =  ""
                                        end

                                     end
                           end
                       else
                            ledgs.cashamt        = 0
                            ledgs.cardamt        = 0
                            ledgs.newmyfeedvalue = 0
                            ledgs.pmtmode        = ""
                            ledgs.giftCrediNote  =  ""
                            ledgs.myusecreditNote = ""
                       end
                      
                       if ledgs.remarks !='subTotal'
                              pdobj           = get_all_of_products($compcodes,ledgs.skucode)
                              ledgs.bldate    = formatted_dated(ledgs.bldate)

                              ledgs.netamount = new_currency_formatted(ledgs.netamount)
                              if pdobj
                                ledgs.barcode = pdobj.pd_barcode
                                ledgs.mrp     = pdobj.pd_mrps
                                catid         = pdobj.pd_category
                                catobj        = find_sel_category($compcodes,catid)
                                if catobj
                                   ledgs.category = catobj.pc_categoryname
                                   ledgs.hsn      = catobj.pc_hsncode
                                end
                               seasobj = get_seasons_details($compcodes,pdobj.pd_season_id)
                               if seasobj
                                  ledgs.seasons = seasobj.ss_name
                               end
                              end
                            #  if $storetype !='outlet'
                                  if ledgs.paytypes == 'R'
                                    ledgs.discamount  = ledgs.discamount.to_f*(-1);
                                    ledgs.qty         = ledgs.qty.to_f*(-1);
                                    ledgs.netamount   = ledgs.netamount.to_f*(-1); 
                                    ledgs.mrp         = ledgs.mrp.to_f*(-1);
                                    ledgs.taxableval  = ledgs.taxableval.to_f*(-1);
                                    ledgs.taxamount   = ledgs.taxamount.to_f*(-1);
                                    ledgs.purchrates  = ledgs.purchrates.to_f*(-1);
                                    neqty             = ledgs.qty.to_f*(-1);
                                    newpurchase       = ledgs.purchrates.to_f*(-1);
                                    newnetamt         = ledgs.netamount.to_f*(-1);
                                    newtaxamt         = ledgs.taxamount.to_f*(-1);
                                    

                                   # ledgs.cashamt    = ledgs.cashamt.to_f*(-1);
                                   # ledgs.cardamt    = ledgs.cardamt.to_f*(-1);
                                   # ledgs.mydeposit  = ledgs.mydeposit.to_f*(-1);
                                    newpurvalues        = neqty.to_f* newpurchase.to_f
                                    newpurvaluesofit    = newnetamt.to_f-(newtaxamt.to_f+newpurvalues.to_f)
                                    ledgs.grossprofit   = newpurvaluesofit*(-1);
                                  else
                                      neqty               = ledgs.qty.to_f
                                      newpurchase         = ledgs.purchrates.to_f
                                      newnetamt           = ledgs.netamount.to_f
                                      newtaxamt           = ledgs.taxamount.to_f
                                      newpurvalues        = neqty.to_f* newpurchase.to_f
                                      newpurvaluesofit    = newnetamt.to_f-(newtaxamt.to_f+newpurvalues.to_f)
                                      ledgs.grossprofit   = newpurvaluesofit
                                  end
                           #   end
                            # cashamt cardamt mydeposit myusecreditNote giftCrediNote
                            
                            newnumber = ledgs.billseries
                            pitems.push ledgs
                    end

                    
              end
        end
     end
    isselect  =  " '' as cashamt,'' as exhd_compcode,'' as exhd_prodcode,'' as pdname,'' as colors,'' as sizes,'' as pdbrand,'' as qty,'' as rates,'' as myusecreditNote,'' as purchrates,'' as grossprofit"
    isselect  += " ,'' as nvalues,'' as discounts,'' as discamount,'' as taxableval,'' as bstatus,'' as skucode,'' as billseries,'' as issuedby,'' as bldate,'' as myvouchers,'' as applycoupon,'' as myccNo,'' as mydirectremark"
    isselect  += " ,'' as taxes, '' as taxamount,'' as netamount,'' as dated,'' as billnumber,'' as cardamt,'' as ccnote,'' as bldate,'' as giftCrediNote,'' as promotype,'' as creditnoteseriesd"
    isselect  += " ,'' as barcode,'' as seasons,'' as category,'' as mrp,'' as hsn,'' as pmtmode,'SaleAll' as remarks,'Total' as paytypes,'' as customername,'' as custmobile,'' as exhtype,'' as exh_forfeedvalue,'' as cremark,'' as purchaseamount"
   subobj   = TrnPrawnTable.select(isselect).all
     if subobj.length >0
        subobj.each do |mysub|
          pitems.push mysub
        end
     end

    colosbal   = 0
    clbqty     = 0
    disctotl   = 0
    colosbal2  = 0
    clbqty2    = 0
    disctotl2  = 0
    tcash      = 0
    tcard      = 0
    tdirect    = 0
    tcash2      = 0
    tcard2      = 0
    tdirect2    = 0
    tgcc        = 0
    tgcc2       = 0
    ttaxable    = 0
    ttaxable2   = 0
    gstamt      = 0
    gstamt2     = 0
    grossprot   = 0
    grossprot2  = 0
    feevaltoal  = 0
    issuecnnote = 0
    CSV.generate(:headers=> true) do |csv|  
    csv << headers5
    csv << headers6    
    csv << headers8
    csv << headers7
    csv << attributes1
    # cashamt cardamt mydeposit myusecreditNote giftCrediNote
        pitems.each do |product|
           if product.paytypes != 'Total'
                  csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME

                  if $storetype =='outlet'
                           if product.paytypes == 'S'  ||  product.paytypes == 'E'  || product.paytypes == 'GF'
                            colosbal    += product.netamount.to_f
                            clbqty      += product.qty.to_f
                            disctotl    += product.discamount.to_f
                            tcash       += product.cashamt.to_f
                            tcard       += product.cardamt.to_f
                            tdirect     += product.mydeposit.to_f
                            tgcc        += product.myusecreditNote.to_f
                            ttaxable    += product.taxableval.to_f
                            gstamt      += product.taxamount.to_f
                            grossprot   += product.grossprofit.to_f
                            feevaltoal  += product.newmyfeedvalue.to_f
                            issuecnnote +=product.issuecreditnote.to_f
                         elsif product.paytypes == 'R'
                            colosbal2  += product.netamount.to_f*(-1)
                            clbqty2    += product.qty.to_f*(-1)
                            disctotl2  += product.discamount.to_f*(-1)
                            grossprot2 += product.grossprofit.to_f*(-1)
                            issuecnnote +=product.issuecreditnote.to_f
                          #  tcash2     += product.cashamt.to_f*(-1)
                          #  tcard2     += product.cardamt.to_f*(-1)
                          #  tdirect2   += product.mydeposit.to_f*(-1)
                           #tgcc2       += product.myusecreditNote.to_f*(-1)
                          # ttaxable2   +=product.taxableval.to_f*(-1)
                         #  gstamt2    += product.taxamount.to_f*(-1)
                        end
                  else
                    colosbal  += product.netamount.to_f
                    clbqty    += product.qty.to_f
                    disctotl  += product.discamount.to_f
                    tcash     += product.cashamt.to_f
                    tcard     += product.cardamt.to_f
                    tdirect   += product.mydeposit.to_f
                    tgcc      += product.myusecreditNote.to_f
                    ttaxable  += product.taxableval.to_f
                    gstamt    += product.taxamount.to_f
                    grossprot += product.grossprofit.to_f
                    feevaltoal+= product.newmyfeedvalue.to_f
                    issuecnnote +=product.issuecreditnote.to_f
                    #  if product.paytypes == 'S'  ||  product.paytypes == 'E'  || product.paytypes == 'GF'
                    #      colosbal  += product.netamount.to_f
                    #      clbqty    += product.qty.to_f
                    #      disctotl  += product.discamount.to_f
                    #   elsif product.paytypes == 'R'
                    #      colosbal2  += 0# product.netamount.to_f
                    #      clbqty2    += 0 # product.qty.to_f
                    #      disctotl2  += 0 # product.discamount.to_f
                    #  end
                  end
                  
                  
                 
            else
                  if product.paytypes == 'Total'
                        product.billseries = 'Total'
                        product.netamount     = "%.2f" % ( colosbal.to_f-colosbal2.to_f)
                        product.qty           = "%.2f" % (clbqty.to_f-clbqty2.to_f)
                        product.discamount    = "%.2f" % (disctotl.to_f-disctotl2.to_f)
                        
                        product.cashamt         = "%.2f" % (tcash.to_f-tcash2.to_f)
                        product.cardamt         = "%.2f" % (tcard.to_f-tcard2.to_f)
                        product.mydeposit       = "%.2f" % (tdirect.to_f-tdirect2.to_f)
                        #product.giftCrediNote = "%.2f" % (tgcc.to_f-tgcc2.to_f)
                        product.myusecreditNote = "%.2f" % (tgcc.to_f-tgcc2.to_f)
                        product.taxableval      = "%.2f" % (ttaxable.to_f-ttaxable2.to_f)
                        product.taxamount       = "%.2f" % (gstamt.to_f-gstamt2.to_f)
                        product.grossprofit     = "%.2f" % (grossprot.to_f-grossprot2.to_f)
                        product.newmyfeedvalue  = "%.2f" % (feevaltoal.to_f)
                        product.issuecreditnote = "%.2f" % issuecnnote.to_f
                      csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                  end
            end
        end
    end

end

private
def self.get_all_of_products(compcodes,pdcode)
    iswhere = " pd_compcode = '#{compcodes}' AND pd_productcode='#{pdcode}'"
     prodobj =  MstProduct.select("mst_products.*,'' as stckqty").where(iswhere).first
     return prodobj
end

private
def self.get_seasons_details(compcode,pdcode)
 szob =  MstSeason.where("ss_compcode=? AND id=?",compcode,pdcode).first
 return szob
end

private
 def self.find_sel_category(compcode,id)
   custobj = MstProductCategory.where("pc_compcode=? AND id=?",compcode,id).first
   return custobj
  end

private
   def self.get_pd_colors(compcodes,pid)
      custobj  = MstColor.where("cls_compcode=? AND id=?",compcodes,pid).first
     return custobj
   end

private
   def self.get_pd_sizess(compcodes,pid)
       custobj  = MstSize.where("sz_compcode=? AND id=?",compcodes,pid).first
     return custobj
   end
 private
 def self.get_sel_brands(compcode,id)
    custobj = MstProductBrand.where("pb_compcode=? AND id=?",compcode,id).first
   return custobj
 end
 private
 def self.get_sel_categorys(compcode,id)
    custobj = MstProductCategory.where("pc_compcode=? AND id=?",compcode,id).first
   return custobj
  end

 private
  def self.daily_receiving
    attributes1 = %w{VoucherNo BillDate AccountLedger PartyName BillNo Item Quantity Rate Amount CGST2.5 SGST2.5 CGST6 SGST6  CGST9 SGST9 CGST14 SGST14}
    attributes3 = %w{voucherno billdate1 accountledger partname billno catitem quantity rates amount cgst25 sgst25 cgst6 sgst6 cgst9 sgst9 cgst14 sgst14}
 
   # headers5    = ["Tally Receiving","","","",""]
   # headers6    = ["From Date : "+formatted_dated($frmDate).to_s,"","Upto Date : "+formatted_dated($uptoDate).to_s,"",""]
   # headers7    = ["","","","",""]
   # headers8    = ["Location : "+$locations.to_s,"","","",""]
    headers9     = ["Cancelled Details","","","",""]
    pitems   = []
    billdates = ''
    k = 0
   
    if all.length >0
        if $execlallsoldregister && $execlallsoldregister.length >0
              $execlallsoldregister.each do |ledgs|
                    if ledgs.billdate1 != billdates
                      k +=1
                    end
                   maxbil   =  get_max_bill_number(ledgs.billdate1)
                   minbil   =  get_min_bill_number(ledgs.billdate1)
                   if maxbil!=minbil             
                     newbils  = minbil.to_s+"-"+maxbil.to_s
                   else
                     newbils  = "`"+minbil.to_s
                   end
                   ledgs.billno = newbils
                    billdates = ledgs.billdate1
                   ledgs.voucherno  = k
                   if ledgs.accountledger =='Rturn'
                     ledgs.accountledger = "Credit Note"
                   end
                   ledgs.rates = ""
                   if $storeID =='AM'
                     ledgs.partname =  "Sara International Retail"
                   end
                  pitems.push ledgs
              end

        end
     end
     m = 0
     cancearr = []
     if $excelallcancelled && $excelallcancelled.length >0
        $excelallcancelled.each do |ledgs|
                    if ledgs.billdate1 != billdates
                      m +=1
                    end
                   maxbil   =  get_max_bill_number(ledgs.billdate1)
                   minbil   =  get_min_bill_number(ledgs.billdate1)
                   if maxbil!=minbil
                     newbils  = minbil.to_s+"-"+maxbil.to_s
                   else
                     newbils  = "`"+minbil.to_s
                   end
                   ledgs.billno = newbils
                    billdates = ledgs.billdate1
                   ledgs.voucherno  = m
                   if ledgs.accountledger =='Rturn'
                     ledgs.accountledger = "Credit Note"
                   end
                   ledgs.rates = ""
                   if $storeID =='AM'
                     ledgs.partname =  "Sara International Retial"
                   end
                  cancearr.push ledgs
              end
     end

    isselect  =  " 'Total' as voucherno,'' as billdate1,'' as accountledger,'' as billno1,'' as partname,'' as billno,'' as catitem,'' as quantity,'' as rates"
    isselect  += " ,'' as amount,'' as cgst25,'' as sgst25,'' as cgst6,'' as sgst6,'' as cgst9,'' as sgst9,'' as cgst14,'' as sgst14"
    isselect  += " ,'' as itemcode, '' as taxes,'' as stores,'' as paytypes"
    
    subobj   = TrnPrawnTable.select(isselect).all
     if subobj.length >0
        subobj.each do |mysub|
          pitems.push mysub
        end
     end

     cancelobj   = TrnPrawnTable.select(isselect).all
     if cancelobj.length >0
        cancelobj.each do |cancelsub|
          cancearr.push cancelsub
        end
     end

    qnty     = 0
    amount   = 0
    cgst25   = 0
    sgst25   = 0
    cgst6    = 0
    sgst6    = 0
    cgst9    = 0
    sgst9    = 0
    cgst14   = 0
    sgst14   = 0
    
    rqnty     = 0
    ramount   = 0
    rcgst25   = 0
    rsgst25   = 0
    rcgst6    = 0
    rsgst6    = 0
    rcgst9    = 0
    rsgst9    = 0
    rcgst14   = 0
    rsgst14   = 0



    cqnty     = 0
    camount   = 0
    ccgst25   = 0
    csgst25   = 0
    ccgst6    = 0
    csgst6    = 0
    ccgst9    = 0
    csgst9    = 0
    ccgst14   = 0
    csgst14   = 0

    crqnty     = 0
    cramount   = 0
    crcgst25   = 0
    crsgst25   = 0
    crcgst6    = 0
    crsgst6    = 0
    crcgst9    = 0
    crsgst9    = 0
    crcgst14   = 0
    crsgst14   = 0


    CSV.generate(:headers=> true) do |csv|
  #  csv << headers5
  #  csv << headers6
  #  csv << headers8
  #  csv << headers7
    csv << attributes1

        pitems.each do |product|
           if product.voucherno != 'Total'
                  csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                  if product.paytypes == 'S'  ||  product.paytypes == 'E'  || product.paytypes == 'GF'
                      qnty     += product.quantity.to_f
                      amount   += product.amount.to_f
                      cgst25   += product.cgst25.to_f
                      sgst25   += product.sgst25.to_f
                      cgst6    += product.cgst6.to_f
                      sgst6    += product.sgst6.to_f
                      cgst9    += product.cgst9.to_f
                      sgst9    += product.sgst9.to_f
                      cgst14   += product.cgst14.to_f
                      sgst14   += product.sgst14.to_f
                   elsif product.paytypes == 'R'
                      rqnty     += product.quantity.to_f
                      ramount   += product.amount.to_f
                      rcgst25   += product.cgst25.to_f
                      rsgst25   += product.sgst25.to_f
                      rcgst6    += product.cgst6.to_f
                      rsgst6    += product.sgst6.to_f
                      rcgst9    += product.cgst9.to_f
                      rsgst9    += product.sgst9.to_f
                      rcgst14   += product.cgst14.to_f
                      rsgst14   += product.sgst14.to_f
                  end


            else
                  if product.voucherno == 'Total'
                        product.voucherno = 'Total'
                        if $storetype =='outlet'
                        product.quantity  = "%.2f" % (qnty.to_f)
                        product.amount    = "%.2f" % (amount.to_f)
                        product.cgst25    = "%.2f" % (cgst25.to_f)
                        product.sgst25    = "%.2f" % (sgst25.to_f)
                        product.cgst6     = "%.2f" % (cgst6.to_f)
                        product.sgst6     = "%.2f" % (sgst6.to_f)
                        product.cgst9     = "%.2f" % (cgst9.to_f)
                        product.sgst9     = "%.2f" % (sgst9.to_f)
                        product.cgst14    = "%.2f" % (cgst14.to_f)
                        product.sgst14    = "%.2f" % (sgst14.to_f)
                        else
                        product.quantity  = "%.2f" % (qnty.to_f-rqnty.to_f)
                        product.amount    = "%.2f" % (amount.to_f-ramount.to_f)
                        product.cgst25    = "%.2f" % (cgst25.to_f-rcgst25.to_f)
                        product.sgst25    = "%.2f" % (sgst25.to_f-rsgst25.to_f)
                        product.cgst6     = "%.2f" % (cgst6.to_f-rcgst6.to_f)
                        product.sgst6     = "%.2f" % (sgst6.to_f-rsgst6.to_f)
                        product.cgst9     = "%.2f" % (cgst9.to_f-rcgst9.to_f)
                        product.sgst9     = "%.2f" % (sgst9.to_f-rsgst9.to_f)
                        product.cgst14    = "%.2f" % (cgst14.to_f-rcgst14.to_f)
                        product.sgst14    = "%.2f" % (sgst14.to_f-rsgst14.to_f)
                        end                      

                      csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                  end
            end

            



        end
          ### FOR CANCELL DATA #######
           if cancearr.length >0
                csv << headers9
                 cancearr.each do |product|
                       if product.voucherno != 'Total'
                              csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                              if product.paytypes == 'S'  ||  product.paytypes == 'E'  || product.paytypes == 'GF'
                                  cqnty     += product.quantity.to_f
                                  camount   += product.amount.to_f
                                  ccgst25   += product.cgst25.to_f
                                  csgst25   += product.sgst25.to_f
                                  ccgst6    += product.cgst6.to_f
                                  csgst6    += product.sgst6.to_f
                                  ccgst9    += product.cgst9.to_f
                                  csgst9    += product.sgst9.to_f
                                  ccgst14   += product.cgst14.to_f
                                  csgst14   += product.sgst14.to_f
                               elsif product.paytypes == 'R'
                                  crqnty     += product.quantity.to_f
                                  cramount   += product.amount.to_f
                                  crcgst25   += product.cgst25.to_f
                                  crsgst25   += product.sgst25.to_f
                                  crcgst6    += product.cgst6.to_f
                                  crsgst6    += product.sgst6.to_f
                                  crcgst9    += product.cgst9.to_f
                                  crsgst9    += product.sgst9.to_f
                                  crcgst14   += product.cgst14.to_f
                                  crsgst14   += product.sgst14.to_f
                              end


                        else
                              if product.voucherno == 'Total'
                                    product.voucherno = 'Total'
                                    if $storetype =='outlet'
                                    product.quantity  = "%.2f" % (cqnty.to_f)
                                    product.amount    = "%.2f" % (camount.to_f)
                                    product.cgst25    = "%.2f" % (ccgst25.to_f)
                                    product.sgst25    = "%.2f" % (csgst25.to_f)
                                    product.cgst6     = "%.2f" % (ccgst6.to_f)
                                    product.sgst6     = "%.2f" % (csgst6.to_f)
                                    product.cgst9     = "%.2f" % (ccgst9.to_f)
                                    product.sgst9     = "%.2f" % (csgst9.to_f)
                                    product.cgst14    = "%.2f" % (ccgst14.to_f)
                                    product.sgst14    = "%.2f" % (csgst14.to_f)
                                    else
                                    product.quantity  = "%.2f" % (cqnty.to_f-crqnty.to_f)
                                    product.amount    = "%.2f" % (camount.to_f-cramount.to_f)
                                    product.cgst25    = "%.2f" % (ccgst25.to_f-crcgst25.to_f)
                                    product.sgst25    = "%.2f" % (csgst25.to_f-crsgst25.to_f)
                                    product.cgst6     = "%.2f" % (ccgst6.to_f-crcgst6.to_f)
                                    product.sgst6     = "%.2f" % (csgst6.to_f-crsgst6.to_f)
                                    product.cgst9     = "%.2f" % (ccgst9.to_f-crcgst9.to_f)
                                    product.sgst9     = "%.2f" % (csgst9.to_f-crsgst9.to_f)
                                    product.cgst14    = "%.2f" % (ccgst14.to_f-crcgst14.to_f)
                                    product.sgst14    = "%.2f" % (csgst14.to_f-crsgst14.to_f)
                                    end

                                  csv << attributes3.map{ |attr| product.send(attr) } #### FOR PRODUCT COMPANY NAME
                              end
                        end


                end
            end ## END CANCELL DATA


    end

end


  private
  def self.get_max_bill_number(dated)
    nedated = new_year_month_days_formatted(dated)
    billobj = TrnTempSaleTally.select("billno").where("billdate = ?",nedated).order("billno DESC").first
    if billobj
      billnos = billobj.billno
    end
    return billnos
    
  end
private
  def self.get_min_bill_number(dated)
    nedated = new_year_month_days_formatted(dated)
    billobj = TrnTempSaleTally.select("billno").where("billdate = ?",nedated).order("billno ASC").first
    if billobj
      billnos = billobj.billno
    end
    return billnos

  end

  private
   def self.new_year_month_days_formatted(dates)
        newdate = ''
        if dates!=nil && dates!=''
             dts    = Date.parse(dates.to_s)
             newdate = dts.strftime("%Y-%m-%d")
        end
        return newdate
   end
  private
def self.to_new_product_items
    attributes1 = %w{SkuCode Product Description Barcode HSN Category Brand UOM Size Color Gender MRP Discount  PurchaseINR PurchaseEURO ImportCharges WholesaleRate Season TargetSale MinOrderLevel MaxOrderLevel ReorderLevel}
    attributes3 = %w{pd_productcode pd_productname pd_productdescription pd_barcode pdhsn pdcatname pdbrand pduom pdsize pdcolor pd_gender pd_mrps pd_discount  pd_purprice_inr pd_purprice_uro pd_importcharges pd_wholesalerate  pdseason pd_targetrate pd_minlevel pd_maxlevel pd_reorderlevel}
    headers1    = ["","PRODUCT LIST","","","",""]
    CSV.generate(:headers=> true) do |csv|
    pitems     = []
    
    $newprodExecl.each do |prodobj|
       compcode  =  prodobj.pd_compcode
       colobj    =  get_pd_colors(compcode,prodobj.pd_colors)
       if colobj
           prodobj.pdcolor = colobj.cls_name
       end
       szobj   = get_pd_sizess(compcode,prodobj.pd_sizes)
       if szobj
           prodobj.pdsize = szobj.sz_size
       end
      pdbrdobj  = get_sel_brands(compcode,prodobj.pd_brand)
      if pdbrdobj
        prodobj.pdbrand = pdbrdobj.pb_brandname
      end
      pdcatobj  = get_sel_categorys(compcode,prodobj.pd_category)
      if pdcatobj
            prodobj.pdcatname = pdcatobj.pc_categoryname
            prodobj.pdhsn   = pdcatobj.pc_hsncode
            prodobj.pdigst    = pdcatobj.pc_igstcode
            prodobj.pdcgst    = pdcatobj.pc_cgstcode
            prodobj.pdsgst    = pdcatobj.pc_sgstcode
      end
     seasobj =  get_seasons_details(compcode,prodobj.pd_season_id)
     if seasobj
        prodobj.pdseason    = seasobj.ss_name
     end
       pitems.push prodobj
    end

    csv << headers1
    csv << attributes1
        pitems.each do |product|
           csv << attributes3.map{ |attr| product.send(attr) }
        end
    end

end


end
