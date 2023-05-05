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
$("#search_dated").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});
function filter_dashboard(){
    var useroot  = $("#userXRoot").val();
    var dated = $("#search_dated").val();
    if( dated == '' ){
        alert("Date is required.") ;
        $("#search_dated").focus()
        return false;
    }
    $("form#myForms").attr("action",useroot+"daily_dashboard/search");   
    $("form#myForms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
