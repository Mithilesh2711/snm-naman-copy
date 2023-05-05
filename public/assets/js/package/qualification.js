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
function filter_qualification(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"qualification/search");
    $("form#myforms").submit();
}

function check_qualification(vl){
    if( vl == 'No Schooling'){
           $(".qualif_in").removeClass("hidden").addClass("hidden");
           $(".qualif_type").removeClass("hidden").addClass("hidden");
           $(".qualif_isprofinter").removeClass("hidden").addClass("hidden");
    }else if(vl == 'Non Matric'){
            $(".qualif_in").removeClass("hidden");
            $(".qualif_type").removeClass("hidden").addClass("hidden");
            $(".qualif_isprofinter").removeClass("hidden").addClass("hidden");
            $("#ql_qualdescription").focus();
    }else{
            $(".qualif_in").removeClass("hidden");
            $(".qualif_type").removeClass("hidden");
            $(".qualif_isprofinter").removeClass("hidden");
            $("#ql_qualdescription").focus();
    }
}