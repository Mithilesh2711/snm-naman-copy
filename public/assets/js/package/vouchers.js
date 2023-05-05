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
$("#voucher_number").keydown(function (event) {
             var keycode  = (event.keyCode ? event.keyCode : event.which);
             if ( keycode == 13 ) { //enter key                    
                filter_voucher();
              }

     });
function filter_voucher(){
    var useroot  = $("#userXRoot").val();
    var sewadar_loantype = $("#sewadar_loantype").val();
    if( sewadar_loantype == ''){
        alert("Please select request type");
        return false;
    }
    $("form#myForms").attr("action",useroot+"vouchers/search");
    $("form#myForms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function alertcancelled(url){
    if( confirm("Are you sure want to cancel ?")){
        window.location = url
    }
}

function check_hide_show(){
    var reamrks = $.trim( $("#vd_remark").val() );
    if( reamrks != ''){
      $(".process_saves").hide();
    }
}