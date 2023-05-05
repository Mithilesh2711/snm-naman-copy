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


function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function get_check_total_sewa(toalsewa){
    var usePath    = $.trim( $("#rootXPath").val() );
     $.ajax({
                     url: usePath+"marriage_parameter/ajax_process",
                     type: 'POST',
                     data: {'toalsewa': toalsewa,'identity':'Y' },
                     async: false,
                     success: function (resp) {
                            if(resp.status){

                            }
                     },
                     error: function () {

                     },
                     cache: false
         });


}
