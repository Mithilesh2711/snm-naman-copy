function isFloatNegativeKey(e,vls){

	  if (e.charCode >= 32 && e.charCode < 127 && !/^-?\d*[.,]?\d*$/.test(vls + '' + String.fromCharCode(e.charCode)))
	  {
		return false;
	  }
	  return true;
}

function isNumberFloatKey(evt)
 {
	  var charCode = (evt.which) ? evt.which : evt.keyCode;
	  if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
		  return false;
	  }
	  return true;
   }

function isNumberKeys(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}

function filter_loan_advance(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"loans_advance/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to cancel ?")){
        window.location = url
    }
}

$("#search_fromdated").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy"  }).datepick("show");
 });

  $("#search_uptodated").click(function() {
     $(this).datepick({ dateFormat: "dd-M-yyyy"}).datepick("show");
 });

//
//    $("#al_requestdate").click(function() {
//       $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
//    });

function get_all_sewadar_by_guarantor(){
    var usePath   = $.trim( $("#rootXPath").val() );
    var depcode   = $.trim( $("#al_guarantordept").val() );
    
    
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'depcode': depcode,'identity':'Y','Guarantor': 'Y'},
                     async: false,
                     success: function (resp) {
                       var sdata  = resp.data;
                      
                       var mhtml  = '<option value="">-Select-</option>';
                                                       
                       var i      = 1;
                        if( resp.status){
                            if(sdata.length >0 ){
                                    $.each(sdata,function(key,leds){
                                        mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewadar_name+'</option>';
                                        i++;
                                    });

                                    
                            }
                        }
                      
                       $("#al_guarantorname").html(mhtml);
                     },
                     error: function () {

                     },
                     cache: false
         });


}


    function get_all_sewadar_by_department(){
            var usePath   = $.trim( $("#rootXPath").val() );
            var depcode   = $.trim( $("#al_depcode").val() );
            var loantype  = $.trim( $("#al_requesttype").val() );
           
             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'depcode': depcode,'loantype':loantype,"processreq":'Y','identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var vdata = resp.sedarname
                               var mhtml  = '<option value="">-Select-</option>';
                               var vhtml  = '<option value="">-Select-</option>';                                   
                               var i      = 1;
                                if( resp.status){
                                    if(sdata.length >0 ){
                                            $.each(sdata,function(key,leds){
                                                mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+'</option>';
                                                i++;
                                            });

                                            $.each(sdata,function(key,led){
                                                vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+'</option>';
                                                
                                            });
                                    }
                                }
                               $("#al_sewadarcode").html(mhtml);
                               $("#alsewdarname").html(vhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });
              



}

function check_loan_advan_skip(){
    var allowskip         = 0
    var checkaccomd       = '';
    var checktotalsea     = '';
    var workingyears      = $.trim( $("#workingyears").val() );
    var noyers = 0
    if( workingyears != '' ){
        workingyears = workingyears.split(" ")
        noyers       = workingyears[0]
    }
    
    if( $("input[name='myexemptionexgratia']:checked").is(":checked") ){
        checkaccomd       = $.trim( $("input[name='myexemptionexgratia']:checked").val() );
     }
     if( $("input[name='myexemptionsewa']:checked").is(":checked") ){
        checktotalsea  = $.trim( $("input[name='myexemptionsewa']:checked").val() );
     }
     if( checkaccomd == 'Y' || checktotalsea == 'Y' ){
        allowskip = 1
     }  
     if( allowskip >0 ){
        $(".process_save").show();
     }
     
}

function fill_from_sewadar_listed(types){
            var usePath           = $.trim( $("#rootXPath").val() );
            var checkaccomd       = '';
            var checktotalsea     = '';
            var allowskip         = 0
            var sewcode           = ""
            if( $("input[name='myexemptionexgratia']:checked").is(":checked") ){
                checkaccomd       = $.trim( $("input[name='myexemptionexgratia']:checked").val() );
             }
             if( $("input[name='myexemptionsewa']:checked").is(":checked") ){
                checktotalsea  = $.trim( $("input[name='myexemptionsewa']:checked").val() );
             }
             if( checkaccomd == 'Y' || checktotalsea == 'Y' ){
                allowskip = 1
             }           
            var fileatt = $.trim( $("#currfilefour").val() );
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar' ){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            var loantype = $.trim( $("#al_requesttype").val() );
            
             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code'){
                                        $("#alsewdarname").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $("#workingyears").val(resp.data[0].totalsewa);
                                        if( loantype == 'Ex-gratia' ){
                                            if(  allowskip <=0 ){
                                                if( resp.data[0].totalsewa <20 ){
                                                    alert("Sewa should be 20 years for apply Ex-gratia");
                                                    $(".process_save").hide();
                                                }else{
                                                     
                                                     $(".process_save").show();
                                                }
                                            }else{
                                                 
                                                 $(".process_save").show();
                                            }
                                            
                                        }else{
                                            $(".process_save").show();
                                        }
                                        if( resp.data[0].outstatnding != '' && resp.data[0].outstatnding != null){
                                            $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        }else{
                                            $(".mytotalout_standing").html(0);
                                        }
                                        
                                        if( resp.data[0].totalemi !='' && resp.data[0].totalemi !=null){
                                            $(".mytotalemi_standing").html(resp.data[0].totalemi);
                                        }else{
                                            $(".mytotalemi_standing").html(0);
                                        }
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $(".dateof_superannuation").html(resp.data[0].supanndate);
                                        $(".my_superannuation").html(resp.data[0].totalsupann);
                                        $(".mydate_regularization").html(resp.data[0].dateregliz);
                                        $("#checkcategory").val(resp.data[0].sw_catcode);
                                        $(".my_category").html(resp.data[0].sw_catgeory);    

                                        if( loantype == 'Loan' || loantype == 'Advance Above 60k' || loantype == 'Special Advance'){
                                            if( resp.data[0].sw_catcode == 'VIT' ){
                                                 $("#al_guarantordept").attr("required",true);
                                                 $("#al_guarantorname").attr("required",true);
                                                $(".myguarantor").removeClass("hidden");
                                                if( fileatt == ''){
                                                    $("#al_guarantorattach").attr("required",true);
                                                }else{
                                                   ///execute
                                                }
                                            }else if( resp.data[0].sw_catcode == 'SDP' ){
                                                    // if( resp.data[0].totalsewa <5 ){
                                                    //         $("#al_guarantordept").attr("required",true);
                                                    //         $("#al_guarantorname").attr("required",true);
                                                    //         $(".myguarantor").removeClass("hidden");
                                                    //         if( fileatt == ''){
                                                    //             $("#al_guarantorattach").attr("required",true);
                                                    //         }else{
                                                    //             ///execute
                                                    //         } 
                                                    // }else{
                                                    //     $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                    //     $("#al_guarantorattach").removeAttr("required");
                                                    //     $("#al_guarantordept").removeAttr("required");
                                                    //     $("#al_guarantorname").removeAttr("required"); 
                                                    // }  
                                            }else{
                                                $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                $("#al_guarantorattach").removeAttr("required");
                                                $("#al_guarantordept").removeAttr("required");
                                                 $("#al_guarantorname").removeAttr("required");

                                            }
                                        }else{
                                                $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                $("#al_guarantorattach").removeAttr("required");
                                                 $("#al_guarantordept").removeAttr("required");
                                                 $("#al_guarantorname").removeAttr("required");
                                        }   

                                     }else if( types == 'sewadar'){
                                         $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $("#workingyears").val(resp.data[0].totalsewa);
                                        if( loantype == 'Ex-gratia' ){
                                            if(  allowskip <=0 ){
                                                if( resp.data[0].totalsewa <20 ){
                                                    alert("Sewa should be 20 years for apply Ex-gratia");
                                                    $(".process_save").hide();
                                                }else{
                                                    
                                                    $(".process_save").show();
                                                }
                                            }else{
                                                    
                                                   $(".process_save").show();
                                            }
                                            
                                        }else{
                                            $(".process_save").show();
                                        }

                                        if( resp.data[0].outstatnding != '' && resp.data[0].outstatnding != null){
                                            $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        }else{
                                            $(".mytotalout_standing").html(0);
                                        }                                        
                                        if( resp.data[0].totalemi !='' && resp.data[0].totalemi !=null){
                                            $(".mytotalemi_standing").html(resp.data[0].totalemi);
                                        }else{
                                            $(".mytotalemi_standing").html(0);
                                        }
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $(".dateof_superannuation").html(resp.data[0].supanndate);
                                        $(".my_superannuation").html(resp.data[0].totalsupann);
                                        $(".mydate_regularization").html(resp.data[0].dateregliz);
                                        $("#checkcategory").val(resp.data[0].sw_catcode);
                                        $(".my_category").html(resp.data[0].sw_catgeory);
                                           if( loantype == 'Loan' || loantype == 'Advance Above 60k' || loantype == 'Special Advance' ){
                                                if( resp.data[0].sw_catcode == 'VIT' ){
                                                    $("#al_guarantordept").attr("required",true);
                                                    $("#al_guarantorname").attr("required",true);

                                                    $(".myguarantor").removeClass("hidden");
                                                    if( fileatt == ''){
                                                        $("#al_guarantorattach").attr("required",true);
                                                    }else{
                                                        //exceute if required
                                                    }
                                                }else if( resp.data[0].sw_catcode == 'SDP' ){
                                                    // if( resp.data[0].totalsewa <5 ){
                                                    //         $("#al_guarantordept").attr("required",true);
                                                    //         $("#al_guarantorname").attr("required",true);
                                                    //         $(".myguarantor").removeClass("hidden");
                                                    //         if( fileatt == ''){
                                                    //             $("#al_guarantorattach").attr("required",true);
                                                    //         }else{
                                                    //             ///execute
                                                    //         } 
                                                    // }else{
                                                    //     $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                    //     $("#al_guarantorattach").removeAttr("required");
                                                    //     $("#al_guarantordept").removeAttr("required");
                                                    //     $("#al_guarantorname").removeAttr("required"); 
                                                    // }    
                                                }else{
                                                    $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                    $("#al_guarantorattach").removeAttr("required");
                                                    $("#al_guarantordept").removeAttr("required");
                                                    $("#al_guarantorname").removeAttr("required");
                                                    $("#al_guarantordept").val('');
                                                    $("#al_guarantorname").val('');
                                                }
                                            }else{
                                                    $(".myguarantor").removeClass("hidden").addClass("hidden");
                                                    $("#al_guarantorattach").removeAttr("required");
                                                    $("#al_guarantordept").removeAttr("required");
                                                    $("#al_guarantordept").val('');
                                                    $("#al_guarantorname").val('');
                                                    $("#al_guarantorname").removeAttr("required");

                                            }      
                                     }
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#myjoining_dated").val('');
                                        $(".mytotalemi_standing").html('');
                                        $(".dateof_superannuation").html('');
                                        $(".my_superannuation").html('');
                                        $(".mydate_regularization").html('');
                                        $(".myguarantor").removeClass("hidden").addClass("hidden");
                                        $("#checkcategory").val('');
                                        $("#al_guarantorattach").removeAttr("required");
                                        $("#al_guarantordept").removeAttr("required");
                                        $("#al_guarantorname").removeAttr("required");
                                        $(".my_category").html('');
                                        $(".process_save").show();
                                        
                                        alert("No record(s) found.");
                                        
                                 }
                              
                               
                             },
                             error: function () {
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#myjoining_dated").val('');
                                        $(".mytotalemi_standing").html('');
                                        $(".dateof_superannuation").html('');
                                        $(".my_superannuation").html('');
                                        $(".mydate_regularization").html('');
                                        $("#checkcategory").val('');
                                        $("#al_guarantorattach").removeAttr("required");
                                        $(".myguarantor").removeClass("hidden").addClass("hidden");
                                        $("#al_guarantordept").removeAttr("required");
                                        $("#al_guarantorname").removeAttr("required");
                                        $(".my_category").html('');
                                        $(".process_save").show();
                             },
                             cache: false
                 });
}

function process_chekout_loans(types){
    var category = $("#checkcategory").val();
    var esstypes  = $.trim( $("#esstypes").val() );
    if( types == 'Advance' ){
        $(".my_advances").show();
        $(".my_loanamt").hide();
        $(".myguarantor").removeClass("hidden").addClass("hidden");
        $("#al_advanceamt").attr("required",true);
        $("#al_loanamount").removeAttr("required");
        $("#al_installpermonth").removeAttr("required");
        $("#other_purpose").removeAttr("required");
        $("#other_purpose").removeClass("hidden").addClass("hidden");
        $("#al_purpose").attr("required",true);
        $("#al_purpose").removeClass("hidden");
        $("#al_guarantordept").removeAttr("required");
        $("#al_guarantorname").removeAttr("required");
        $("#other_purpose").val('');
        $("#al_guarantordept").val('');
        $("#al_guarantorname").val('');
        $(".process_exgratiadata").removeClass("hidden").addClass("hidden");
        $("#myexemptionexgratia").prop("checked",false);
        $("#myexemptionsewa").prop("checked",false);
    }else if( types == 'Loan' || types == 'Advance Above 60k' || types == 'Special Advance' ){
        $(".my_advances").hide();
        $(".my_loanamt").show();
        $("#al_advanceamt").removeAttr("required");
        $("#al_loanamount").attr("required",true);
        $("#al_installpermonth").attr("required",true);
        $("#other_purpose").removeAttr("required");
        $("#other_purpose").removeClass("hidden").addClass("hidden");
       
        if( category == 'VIT' ){
            $("#al_guarantordept").attr("required",true);
            $("#al_guarantorname").attr("required",true);

        }else{
            $("#al_guarantordept").removeAttr("required");
            $("#al_guarantorname").removeAttr("required");
            $("#al_guarantordept").val('');
            $("#al_guarantorname").val('');
        }
       
        $("#other_purpose").val('');
        $("#al_purpose").attr("required",true);
        $("#al_purpose").removeClass("hidden");
        $(".process_exgratiadata").removeClass("hidden").addClass("hidden");
        $("#myexemptionexgratia").prop("checked",false);
        $("#myexemptionsewa").prop("checked",false);
    }else if( types == 'Wheat Advance' ){
        $(".my_advances").hide();
        $(".my_loanamt").show();
        $("#al_advanceamt").removeAttr("required");
        $("#al_loanamount").attr("required",true);
        $("#al_installpermonth").attr("required",true);
        $("#other_purpose").removeAttr("required");
        $("#other_purpose").removeClass("hidden").addClass("hidden");
        $("#al_guarantordept").removeAttr("required");
        $("#al_guarantorname").removeAttr("required");       
        $("#other_purpose").val('');
        $("#al_purpose").attr("required",true);
        $("#al_purpose").removeClass("hidden");  
        $("#al_guarantordept").val('');
        $("#al_guarantorname").val('');  
        $(".myguarantor").removeClass("hidden").addClass("hidden");
        $(".process_exgratiadata").removeClass("hidden").addClass("hidden");
        $("#myexemptionexgratia").prop("checked",false);
        $("#myexemptionsewa").prop("checked",false);
    }else if(  types == 'Ex-gratia'){    
        $("#al_purpose").removeAttr("required");
        $("#other_purpose").attr("required",true);
        $("#al_purpose").removeClass("hidden").addClass("hidden");
        $("#other_purpose").removeClass("hidden");
        $("#al_loanamount").removeAttr("required");
        $("#al_installpermonth").removeAttr("required");
        $("#al_purpose").val('');
        

        $(".my_loanamt").hide();
        $(".my_advances").show();
        $("#al_advanceamt").attr("required",true);
        $("#al_loanamount").removeAttr("required");
        $("#al_guarantordept").removeAttr("required");
        $("#al_guarantorname").removeAttr("required");
        $("#al_guarantordept").val('');
        $("#al_guarantorname").val('');
        $(".myguarantor").removeClass("hidden").addClass("hidden");
        $(".process_exgratiadata").removeClass("hidden");



    }else{
        $("#al_installpermonth").removeAttr("required");
        $("#other_purpose").removeAttr("required");       
        $("#other_purpose").removeClass("hidden").addClass("hidden");
        $("#al_purpose").attr("required",true);
        $("#al_purpose").removeClass("hidden");
        $(".my_advances").show();
        $(".my_loanamt").hide();
        $("#al_advanceamt").attr("required",true);
        $("#al_loanamount").removeAttr("required");
        $("#al_guarantordept").removeAttr("required");
        $("#al_guarantorname").removeAttr("required");
        $("#al_guarantordept").val('');
        $("#al_guarantorname").val('');
        $("#other_purpose").val('');
        $(".myguarantor").removeClass("hidden").addClass("hidden");
        $(".process_exgratiadata").removeClass("hidden").addClass("hidden");
        $("#myexemptionexgratia").prop("checked",false);
        $("#myexemptionsewa").prop("checked",false);
    }
    if( esstypes =='swd' ){
        setTimeout(function(){ fill_from_sewadar_listed('code'); },500);
       
    }   
}

function exportDataToExcel(tabled, filename){
          var downloadurl;
          var fileType    = 'application/vnd.ms-excel';
           var tableSelect = document.getElementById(tabled);
           var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
           filename        = filename?filename+'.xls':'advance_loan_request.xls';
           downloadurl     = document.createElement("a");
           document.body.appendChild(downloadurl);

            if(navigator.msSaveOrOpenBlob){
                         var blob = new Blob(['\ufeff', dataHTML],{type:  fileType });
                         navigator.msSaveOrOpenBlob( blob, filename);
                }else
                  {
                           downloadurl.href = 'data:' + fileType + ', ' + dataHTML;
                           downloadurl.download = filename;
                           downloadurl.click();
                  }

  }

  function check_validities(){
            var al_depcode     = $.trim( $("#al_depcode").val() );
            var al_sewadarcode = $.trim( $("#al_sewadarcode").val() );
            var sewdarname     = $.trim( $("#sewdarname").val() );
            var al_requestdate = $.trim( $("#al_requestdate").val() );
            var al_requesttype = $.trim( $("#al_requesttype").val() );
            var al_advanceamt  = $.trim( $("#al_advanceamt").val() );
            var al_loanamount  = $.trim( $("#al_loanamount").val() );
            
            var guarantor         = $('#al_guarantorattach').get(0).files[0];
            var al_guarantordept  = $.trim( $("#al_guarantordept").val() );
            var al_guarantorname  = $.trim( $("#al_guarantorname").val() );
            var al_purpose        = $.trim( $("#al_purpose").val() );
            var remarks           = $.trim( $("#exemptionremark").val() );
            var checkaccomd       = '';
            var checktotalsea     = '';
            if( $("input[name='myexemptionexgratia']:checked").is(":checked") ){
                checkaccomd       = $.trim( $("input[name='myexemptionexgratia']:checked").val() );
             }

             if( $("input[name='myexemptionsewa']:checked").is(":checked") ){
                checktotalsea  = $.trim( $("input[name='myexemptionsewa']:checked").val() );
             }

            var counts = 0;
            if( al_depcode == ''){
                counts = 1
            }
            if( al_sewadarcode == ''){
                 counts = 1
            }
           
            if( al_requestdate == ''){
                counts = 1
            }
            if( al_requesttype == ''){
                counts = 1
            }
            
            if( al_advanceamt == ''  && al_loanamount == '' ){
                 counts = 1
                
            }
           if( al_requesttype == 'Loan' || al_requesttype == 'Advance Above 60k'){ 
                if( typeof(guarantor) != "undefined" ){
                    // execute if file attached
                }else{
                    counts = 1;
                }
                if( al_guarantordept == ''){
                    counts = 1;
                }
                if( al_guarantorname == ''){
                    counts = 1;
                }

           }
           if( al_purpose == ''){
            counts = 1;
           }
           if( checkaccomd == 'Y' || checktotalsea=='Y'){
                if( remarks == ''){
                    alert("Exemption remark is required");
                    counts = 1;
                }
           }
          
            if( counts <=0 ){
                $(".process_save").hide();
            }

  }