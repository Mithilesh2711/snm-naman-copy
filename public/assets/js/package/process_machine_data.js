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
function process_biomatric_data(){
    if( confirm("Are you sure want to process?")){
        $(".process_dailyattd").removeClass("hidden");
        $(".noprocess_dailyattd").removeClass("hidden").addClass("hidden");
        $("form#myforms").submit();
    }
   
}
$("#from_date").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy"  }).datepick("show");
});

