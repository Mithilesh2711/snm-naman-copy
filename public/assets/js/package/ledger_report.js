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

$("#from_date").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });

  $("#upto_date").click(function() {
     $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){} }).datepick("show");
 });


function filter_ledger_report(){
    var useroot = $("#userXRoot").val();

    $("form#myforms").attr("action",useroot+"ledger_report/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

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
    if( types == 'code'){
        sewcode = $.trim( $("#al_sewadarcode").val() );
    }else if( types == 'sewadar'){
         sewcode = $.trim( $("#alsewdarname").val() );
    }
    
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

                             }else if( types == 'sewadar'){
                                 $("#al_sewadarcode").val(sewcode);
                                $(".my_dpeartmentname").html(resp.data[0].department);
                                $(".myjoining_dated").html(resp.data[0].joiningdate);
                                $(".mytotalworking_year").html(resp.data[0].sewduration);
                                $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                $("#myjoining_dated").val(resp.data[0].joiningdate);
                             }
                         }else{
                                $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                                $("#myjoining_dated").val('');
                                alert("No record(s) found.");
                         }
                      
                       
                     },
                     error: function () {
                               $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                                $("#myjoining_dated").val('');
                     },
                     cache: false
         });
}

function print_ledger_report(){
    var usePath   = $.trim( $("#rootXPath").val() );
    var sewacode  = $.trim( $("#al_sewadarcode").val() );
    var purl      = $.trim( $("#printurl").attr("rel") );
    var from_date = $.trim( $("#from_date").val() );
    var upto_date = $.trim( $("#upto_date").val() );
    var leavecode = $.trim( $("#leave_type").val() );
     if( leavecode == '' ){
         alert("Please select leave type");
         $("#leave_type").focus();
         return false;
     }else if( sewacode == '' ){
        alert("Please select sewadar code/name");
        $("#al_sewadarcode").focus()
        return false;
    }

        $.ajax({
            url: usePath+"ledger_report/ajax_process",
            type: 'POST',
            data: {'sewacode':sewacode,'from_date':from_date,'upto_date':upto_date,'leavecode':leavecode,'identity':'Y'},
            async: false,
            success: function (resp) {
                    if( resp.status){
                        window.open(purl,'_blank')
                    }else{
                        alert("No Record(s) Found.")
                    }
            },
            error: function () {

            },
            cache: false
    });
}


