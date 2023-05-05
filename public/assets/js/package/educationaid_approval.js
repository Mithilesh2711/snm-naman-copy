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

$("#search_from_date").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });

  $("#search_upto_date").click(function() {
     $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){} }).datepick("show");
 });

function filter_approval(){
    var useroot = $("#userXRoot").val();
    var approvedby = $("#approvedby").val();
    var deptcode   = $("#voucher_department").val();
    var userslogin = $("#userslogin").val();
    if(userslogin !='hr' ){
        if( approvedby != '' ){
            if( deptcode == '' ){
            alert("Department is required");
            return false;
            }
        }
    }
    $("form#myForms").attr("action",useroot+"educationaid_approval/search");   
    $("form#myForms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function request_approval(id,status){
    var useroot = $("#userXRoot").val();
    window.location = useroot+"educationaid_approval/"+id+"?st="+status
}
