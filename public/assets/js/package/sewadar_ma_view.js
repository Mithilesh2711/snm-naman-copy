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
    var useroot  = $("#rootXPath").val();
    var depcode  = $("#al_depcode").val(); 
    var sewcode  = $("#alsewdarname").val(); 
   
    if( depcode == '' ){
        alert("Department is required.");
        $("#al_depcode").focus(); 
        return false;
    }else if( sewcode == '' ){
        alert("Sewadar is required.");
        $("#ls_empcode").focus(); 
        return false;
    }
    $("form#myforms").attr("action",useroot+"sewadar_ma_view/search");
    $("form#myforms").submit();
}



 $("#ls_fromdate").click(function() {
          $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){setTimeout(function(){ get_number_of_days();},500);} }).datepick("show");
       });

        $("#ls_todate").click(function() {
           $(this).datepick({ dateFormat: "dd/mm/yyyy",onSelect:function(evt){ setTimeout(function(){ get_number_of_days();},500);} }).datepick("show");
       });

       $("#from_month").click(function() {
        $(this).datepick({ dateFormat: "mm-yyyy" }).datepick("show");
     });

      $("#from_uptomonth").click(function() {
         $(this).datepick({ dateFormat: "mm-yyyy"}).datepick("show");
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
                                         vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+' ('+led.sw_sewcode+')</option>';

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