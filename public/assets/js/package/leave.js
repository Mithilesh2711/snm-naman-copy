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
function process_change_approved_status(empcode,leavecode,leavstatus,id){
    var usePath          = $.trim( $("#userXRoot").val() );
    var formData         = new FormData();    
    formData.append("identity", "CHANGESTATUS");
    formData.append("leavecode", leavecode);
    formData.append("sewadarcode", empcode);
    formData.append("leaveid", id);
    formData.append("leavestatus", leavstatus);

        $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         if( resp.status){
                             if( leavstatus == 'P'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-purple"></i> Pending ')
                              }else if(  leavstatus == 'A'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-success"></i> Approved ')
                              }else if(  leavstatus == 'D'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-danger"></i> Rejected ')
                              }else if(  leavstatus == ''){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-info"></i> Pending ')
                              }
                              alert(resp.message);
                         }else{
                              $("#selected_status"+id).html('Pending')
                              alert(resp.message);
                         }

                     },
                     error: function () {
                        $("#selected_status"+id).html('Pending')
                     },
                     cache: false
             });
}
$("#search_fromdated").click(function() {
    $(this).datepick({ dateFormat: "dd/mm/yyyy"  }).datepick("show");
 });

  $("#search_uptodated").click(function() {
     $(this).datepick({ dateFormat: "dd/mm/yyyy"}).datepick("show");
 });


function setoutfocus(id){
   $("#"+id).focus();
   $("#"+id).val('');
}

function filter_listed_leaves(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"leave/search");
    $("form#myforms").submit();
}

function get_remaining_leave_balance(){
    var usePath          = $.trim( $("#rootXPath").val() );
    var formData         = new FormData();
    var leavecode        = $.trim( $("#ls_leave_code").val() );
    var empcode          = $.trim( $("#al_sewadarcode").val() );
    var categery         = $.trim( $("#ls_category").val() );
    formData.append("identity", "RMNLEAVEBAL");
    formData.append("leavecode", leavecode);
    formData.append("sewadarcode", empcode);
    formData.append("category", categery);
   

        $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         if( resp.status){
                              var sdata = resp.data;
                              $("#ls_remainleave").val(sdata);
                              if( sdata <=0 ){
                                  $("#processleave").hide();
                              }else{
                                $("#processleave").show();
                              }
                         }else{
                              $("#ls_remainleave").val('');
                         }
                        //  if( resp.rlnumdays<=0){
                        //     $("#ls_days").val('');
                        //  }else{
                        //      $("#ls_days").val(resp.rlnumdays);
                        //  }
                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                         

                     },
                     error: function () {
                        $("#ls_remainleave").val('');
                        $("#ls_days").val('');
                     },
                     cache: false
             });

}

function checkValidate(stringval,id){
       var pattern = /^([0-9]{2})\/([0-9]{2})\/([0-9]{4})$/;
        if (pattern.test(stringval)) {
            //
        }else{            
            alert(stringval + ' is not valid.  Format must be dd/mm/yyyy ' + 'and the date value must be valid for the calendar.');
            setTimeout(function(){ setoutfocus(id);},500);
            
        }
   
}
function clear_all_selected_leave_rules(){
    $("#ls_fromdate").val('');
    $("#ls_todate").val('');
    $("#ls_days").val('');
    $("#halfdayallowed").val('');
    $("#ls_leavereson").val('');
    $("#allowedleave").val('');
    $(".new_leave_day").removeClass("hidden").addClass("hidden");
    $(".leave_day").removeClass("hidden").addClass("hidden");
    $("#ls_halffull_1").prop("checked",true);
    $("#ls_firsthalfsec_1").prop("checked",false);
    $("#ls_firsthalfsec_2").prop("checked",false);

}

function process_leave_rules(){
    var usePath        = $.trim( $("#rootXPath").val() );
    var formData       = new FormData();
    var ls_empcode     = $.trim( $("#alsewdarname").val() );
    var ls_leave_code  = $.trim( $("#ls_leave_code").val() );
    var ls_fromdate    = $.trim( $("#ls_fromdate").val() );
    var ls_todate      = $.trim( $("#ls_todate").val() );    
    var catgeory       = $.trim( $("#ls_category").val() );
    var numberdys      = $.trim( $("#ls_days").val() );
    var hlfdays        = $.trim( $("input[name='ls_halffull']:checked").val() );
     var vl            = $.trim( $("#ls_leave_code option:selected").val() );
     var mid           = $.trim( $("#mid").val() );
     
    var counts         = 0;

    if( ls_empcode == '' ){
          counts = 1;
    }else if( ls_leave_code == '' ){
          counts = 1;

    }else if( ls_fromdate == '' ){
          counts = 1;
    }else if( ls_todate == '' ){
          counts = 1;
    }
   

   if( ls_fromdate != '' && ls_todate !='' ){
        // if( ls_fromdate > ls_todate ){
        //     counts = 1;
            
        // }
        
   }
   
   $(".leave_day").removeClass("hidden").addClass("hidden");
   if( counts <=0 ){
    formData.append("identity", "LEAVERULE");
    formData.append("catgeory", catgeory);
    formData.append("leavecode", ls_leave_code);
    formData.append("ls_empcode", ls_empcode);
    formData.append("numberdys", numberdys);
    formData.append("fromdate", ls_fromdate);
    formData.append("uptodated", ls_todate);
    formData.append("mid", mid);
   
        $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {

                         if( resp.status ){                             
                                 var netds = 0
                                 if( hlfdays == 'H' ){
                                     netds = eval(resp.totdays)-eval('.5')
                                 }else{
                                     netds = resp.totdays
                                 }
                                 $("#allowedleave").val(resp.totdays);
                                 $("#ls_days").val(netds);
                                 if( resp.halfday == 'Y' ){
                                      $(".leave_day").removeClass("hidden");
                                     
                                      if( hlfdays == 'H' ){
                                          $("#ls_halffull_1").prop("checked",false);
                                          $("#ls_halffull_2").prop("checked",true);
                                          $("#ls_firsthalfsec_1").prop("checked",true);
                                          $("#ls_firsthalfsec_2").prop("checked",false);
                                          $(".new_leave_day").removeClass("hidden");

                                      }else{
                                          $("#ls_halffull_1").prop("checked",true);
                                          $("#ls_halffull_2").prop("checked",false);
                                          $("#ls_firsthalfsec_1").prop("checked",false);
                                          $("#ls_firsthalfsec_2").prop("checked",false);
                                          $(".new_leave_day").removeClass("hidden").addClass("hidden");;
                                      }
                                 }else{
                                      $(".leave_day").removeClass("hidden").addClass("hidden");
                                      $(".new_leave_day").removeClass("hidden").addClass("hidden");
                                      $("#ls_halffull_1").prop("checked",true);
                                      $("#ls_halffull_2").prop("checked",false);
                                      $("#ls_firsthalfsec_1").prop("checked",false);
                                      $("#ls_firsthalfsec_2").prop("checked",false);

                                 }
                                 $(".processleave").show();

                             }else{
                                     $("#ls_days").val('');
                                     $("#allowedleave").val('');
                                     alert(resp.message)
                                     $(".processleave").hide();
                             }
                             $("#halfdayallowed").val(resp.halfday);

                     },
                     error: function () {
                          $("#halfdayallowed").val('');
                          $(".leave_day").removeClass("hidden").addClass("hidden");
                          $("#ls_halffull_1").prop("checked",true);
                          $("#ls_halffull_2").prop("checked",false);
                          $("#ls_firsthalfsec_1").prop("checked",false);
                          $("#ls_firsthalfsec_2").prop("checked",false);
                     },
                     cache: false
             });
                if( vl == 'SL'){
                    setTimeout(function(){ get_short_leave();},500);
                }
                //get_remaining_leave_balance();   
   }
    
}
function check_short_leave_listed(){
    var lsleave = $.trim( $("#ls_days").val() );
    $("#ls_remainleave").val(lsleave);
}

function get_short_leave(){
    var vl         =  $.trim( $("#ls_leave_code option:selected").val() );
    var chdays     =  $.trim( $("#allowedleave").val() );
     if( $.trim(vl) != '' ){
             if( vl == 'SL' ){
                        $(".new_leave_day").removeClass("hidden");
                        $("#ls_days").val('.25');
                         $("#ls_firsthalfsec_1").prop("checked",true);
                         $("#ls_firsthalfsec_2").prop("checked",false);
                         //setTimeout(function(){ check_short_leave_listed();},500);
                         
             }else{
                       $("#ls_days").val(chdays);
                       $(".new_leave_day").removeClass("hidden").addClass("hidden");
                         $("#ls_firsthalfsec_1").prop("checked",false);
                         $("#ls_firsthalfsec_2").prop("checked",false);
             }
     }
}
function get_leave_types(){
    var usePath          = $.trim( $("#rootXPath").val() );
    var formData         = new FormData();
    var catgeory         = $.trim( $("#ls_category").val() );
    var sewcodes         =  $.trim( $("#alsewdarname").val() );
    formData.append("identity", "LEAVECATGEOY");
    formData.append("catgeory", catgeory);
   formData.append("sewcodes", sewcodes);

        $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         var vhtml = '<option value="">-Select-</option>';
                         if( resp.status ){
                                  var sdata = resp.data;
                                  if ( sdata.length >0 ){
                                     $.each(sdata,function(keys,lv){
                                        vhtml +='<option value="'+lv.attend_leaveCode+'">'+lv.attend_leavetype+'</option>';
                                     });
                                  }
                         }
                         $("#ls_leave_code").html(vhtml);
                     },
                     error: function () {
                         
                     },
                     cache: false
             });
}



function check_all_leave_ruled(){
   
    var ls_empcode     = $.trim( $("#alsewdarname").val() );
    var ls_leave_code  = $.trim( $("#ls_leave_code").val() );
    var ls_fromdate    = $.trim( $("#ls_fromdate").val() );
    var ls_todate      = $.trim( $("#ls_todate").val() );
    var ls_leavereson  = $.trim( $("#ls_leavereson").val() );
    var avails         = $.trim( $("input[name='ls_halffull']:checked").val() );
    var periods        = $.trim( $("input[name='ls_firsthalfsec']:checked").val() );
    var ls_days        = $.trim( $("#ls_days").val() );
    var ruledaysgo      = $.trim( $("#leaveruledays").val() );
    var ls_remainleave  = $.trim( $("#ls_remainleave").val() ) != '' ? $.trim( $("#ls_remainleave").val() ) : 0 ;
    var  date1  = ls_fromdate !='' ? new Date(ls_fromdate) : '';
    var  date2 = ls_todate != '' ? new Date(ls_todate) : '';
    var counts         = 0;
    
    if( ls_empcode == '' ){
          counts = 1;
    }else if( ls_leave_code == '' ){
          counts = 1;
        
    }else if( ls_fromdate == '' ){
          counts = 1;
    }else if( ls_todate == '' ){
          counts = 1;
    }else if( ls_leavereson == '' ){
          counts = 1;
    }

//    if( ls_fromdate != '' && ls_todate !='' ){   
//         if( date2 < date1 ){
//             counts = 1;
//             alert("Upto date should be greater than from date.");
//             $("#ls_todate").focus()
//             return false;
//         }
//    }
    
   if( ls_days <=0 ){
       alert("Number of days should be greater than zero.");
       return false;
   }
   if( parseFloat(ls_days) >0 && parseFloat(ls_days)>parseFloat(ruledaysgo) ){
       alert("Number of days should not be greater leave taken one go.");
       return false;
   }
   if( ls_leave_code != 'LWM' &&  ls_leave_code != 'OD'  &&  ls_leave_code != 'ML' &&  ls_leave_code != 'SPL' ){
        if( parseFloat(ls_remainleave) <=0 ){
            alert("Remaining leave is required");
            return false;  
        }else if( parseFloat(ls_days) >parseFloat(ls_remainleave) ){
            alert("Could not avail more than Remaining leave");
            return false;       

        }
   }
   
    
    if( counts <=0 ){

          $("#firsthalfsec").val(avails);
          $("#firstperiodsec").val(periods);
          $(".submit-section").hide();
    }
}

function filter_apply_leaves(){
    var useroot = $("#rootXPath").val();
    $("form#myforms").attr("action",useroot+"leave/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function commonalertChecked(url,meesge){
    if( confirm(meesge)){
        window.location = url
    }
}


function get_leave_balance(){
    var usePath          = $.trim( $("#rootXPath").val() );
    var formData         = new FormData();
    var leavecode        = $.trim( $("#ls_leave_code").val() );
    var empcode          = $.trim( $("#ls_empcode").val() );
    var categery         = $.trim( $("#ls_category").val() );
    formData.append("identity", "REMAINLEAVE");
    formData.append("leavecode", leavecode);
    formData.append("sewadarcode", empcode);
    formData.append("categery", categery);
    $("#ls_halffull_2").removeAttr("checked");
    $("#ls_halffull_1").attr("checked",true);

        $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         if( resp.status){
                              var sdata = resp.data;
                              $("#ls_remainleave").val(sdata.lb_closingbal);
                         }else{
                              $("#ls_remainleave").val('');
                         }
                         $("#leaveruledays").val(resp.rlnumdays);
                         setTimeout(function(){ clear_all_selected_leave_rules();},500);

                     },
                     error: function () {
                         $("#ls_remainleave").val('');
                     },
                     cache: false
             });

}

function check_half_fuldays(){
    var ls_halffull = $("input[name='ls_halffull']:checked").val();
    var chdays  =   $.trim( $("#allowedleave").val() );
        if( ls_halffull == 'H' ){
            $(".new_leave_day").removeClass("hidden");
            $("#ls_firsthalfsec_2").removeAttr("checked");
            $("#ls_firsthalfsec_1").prop("checked",true);
              if ( chdays >1 ){
                  var nleave = eval(chdays)-eval('.5');
                  $("#ls_days").val(nleave);
              }else{
                  $("#ls_days").val('.5');
              }
             

        }else{
            $("#ls_firsthalfsec_2").removeAttr("checked");
            $("#ls_firsthalfsec_1").removeAttr("checked");
            $(".new_leave_day").removeClass("hidden").addClass("hidden");
            //$("#ls_days").val(chdays);
            get_number_of_days();
        }
}

function get_avail_leavevalidate(){
    
    var ls_days =   $.trim( $("#ls_days").val() );
    var chdays  =   $.trim( $("#allowedleave").val() );
    if( chdays  == 1 ){
        if( parseFloat(ls_days) >1 ){
                alert("Enter no of days should be less than equal to 1 ");
                $("#ls_days").val(chdays)
                return false;
         }else{
             if( parseFloat(ls_days) <1 ){
                 $(".new_leave_day").removeClass("hidden");
                 $(".avail_remarks").removeClass("hidden");
                 $("#ls_halffull_1").removeAttr("checked");
                 $("#ls_halffull_2").attr("checked",true)
             }else{
                  $(".new_leave_day").removeClass("hidden").addClass("hidden");
                  $(".avail_remarks").removeClass("hidden").addClass("hidden");
                  $("#ls_halffull_1").attr("checked",true);
                  $("#ls_halffull_2").removeAttr("checked");
             }
             
         }
    }else{
         $(".new_leave_day").removeClass("hidden");
         $(".avail_remarks").removeClass("hidden");
         $("#ls_halffull_1").attr("checked",true);
         $("#ls_halffull_2").removeAttr("checked")
    }
    
}
function get_number_of_days(){
    var usePath          = $.trim( $("#rootXPath").val() );
    var formData         = new FormData();   
    var fromdated        = $.trim( $("#ls_fromdate").val() );
    var uptodated        = $.trim( $("#ls_todate").val() );
    var leavecode        = $.trim( $("#ls_leave_code").val() );
    var categery         = $.trim( $("#ls_category").val() );
    
    formData.append("identity", "Y");
    formData.append("frmdate", fromdated);
    formData.append("uptodate", uptodated);
    formData.append("leavecode", leavecode);
    formData.append("categery", categery);
    $(".processleave").hide();
    
    $.ajax({
                     url: usePath+"leave/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         if( resp.status == '5' || resp.status == '6'){
                              alert(resp.message);
                               $("#ls_days").val('');                               
                               $("#allowedleave").val('');
                               $("#ls_firsthalfsec_1").prop("checked",false);
                               $("#ls_firsthalfsec_2").prop("checked",false);
                               $(".new_leave_day").removeClass("hidden").addClass("hidden");
                               if(resp.status == '5'){
                                   $("#ls_fromdate").val('');
                                   $("#ls_fromdate").focus();
                               }else if(resp.status == '6'){
                                    $("#ls_todate").val('');
                                    $("#ls_todate").focus();
                               }                              

                           }
                          if( resp.status == '2'){
                              alert(resp.message);
                               $("#ls_days").val('');
                               $("#ls_todate").val('');
                               $("#allowedleave").val('');
                               $("#ls_firsthalfsec_1").prop("checked",false);
                               $("#ls_firsthalfsec_2").prop("checked",false);
                               $(".new_leave_day").removeClass("hidden").addClass("hidden");
                               $("#ls_todate").focus();
                               return false;
                          }
                         if( leavecode == 'ML' ){
                              $("#ls_days").val(resp.data);
                              $("#allowedleave").val(resp.data);
                              $("#ls_todate").val(resp.updated);
                              $(".processleave").show();
                              return false
                         }
                         if( leavecode == 'SL' ){
                            if( resp.data >1 ){
                                     $("#ls_days").val('');
                                     $(".new_leave_day").removeClass("hidden").addClass("hidden");
                                     $("#ls_firsthalfsec_1").prop("checked",false);
                                     $("#ls_firsthalfsec_2").prop("checked",false);
                                     alert("Short leave should be .25, Your apply date diffrence should be one day.");
                                     return false;
                            }else{
                                 setTimeout(function(){ process_leave_rules();},500);
                                 return false;
                            }
                         }
                         if( resp.status == '3' ){
                              $("#ls_days").val(resp.data);
                              $("#allowedleave").val(resp.data);
                               if( resp.data <= 1){
                                 // $(".leave_day").removeClass("hidden");
                                  //$("#ls_days").removeAttr('readonly',true);
                               }else{
                                  $(".leave_day").removeClass("hidden").addClass("hidden");
                                  // $("#ls_days").Attr('readonly',true);
                               }
                         }else{
                             $("#ls_days").val('');                           
                            // $("#ls_days").Attr('readonly',true);
                             $("#allowedleave").val('');
                         }
                         if( uptodated !='' && fromdated !=''){
                             setTimeout(function(){ get_short_leave();});
                         }
                       
                         setTimeout(function(){ process_leave_rules();},500);
                     },
                     error: function () {
                          $("#ls_days").val('');
                          // $("#ls_days").Attr('readonly',true);
                           $("#allowedleave").val('');
                          
                     },
                     cache: false
             });
}

 $("#ls_fromdate").click(function() {
          $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){setTimeout(function(){ get_number_of_days();},500);} }).datepick("show");
       });

        $("#ls_todate").click(function() {
           $(this).datepick({ dateFormat: "dd/mm/yyyy",onSelect:function(evt){ setTimeout(function(){ get_number_of_days();},500);} }).datepick("show");
       });

function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );

             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'depcode': depcode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var vdata = resp.sedarname
                               var mhtml  = '<option value="">-Select-</option>';
                               var vhtml  = '<option value="">-Select-</option>';

                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+'</option>';
                                         i++;
                                    });

                                     $.each(vdata,function(key,led){
                                         vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+'</option>';

                                    });
                              }
                               $("#al_sewadarcode").html(mhtml);
                               $("#alsewdarname").html(vhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}

function fill_from_sewadar_listed(types){
            var usePath  = $.trim( $("#rootXPath").val() );
            var sewcode  = ""
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar'){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            var catname  = '';
             var result  = '';
             var catcode = '';
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
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $("#ls_referencecode").val(resp.data[0].sw_oldsewdarcode);                                         
                                         catcode = resp.data[0].sw_catcode;
                                        $("#ls_category").val(catcode);
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                     }else if( types == 'sewadar'){
                                        $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $("#ls_referencecode").val(resp.data[0].sw_oldsewdarcode);
                                        catcode = resp.data[0].sw_catcode;                                        
                                        $("#ls_category").val(catcode);
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                        
                                     }
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#ls_referencecode").val('');
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                        alert("No record(s) found.");
                                 }


                             },
                             error: function () {
                                       $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#ls_referencecode").val('');
                             },
                             cache: false
                 });
}