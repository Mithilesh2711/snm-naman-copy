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

function filter_headoffice(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"head_office/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function filter_sublocation(){
    var useroot = $("#userXRoot").val();
    $("form#submyforms").attr("action",useroot+"head_office/sublocation/search");
    $("form#submyforms").submit();
}
function check_tab_listing(tbsname){
            var usePath    = $.trim( $("#rootXPath").val() );
            if( tbsname == 'HO'){
               $("#basic-justified-tab1").removeClass("active").addClass("active");
               $("#basic-justified-tab2").removeClass("active");
            }else if( tbsname == 'SHO'){
                $("#basic-justified-tab1").removeClass("active");
                $("#basic-justified-tab2").removeClass("active").addClass("active");
            }
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'tabsname': tbsname,'identity':'TBS'},
                             async: false,
                             success: function (resp) {
                                 if( resp.status){
                                     // exceute if required
                                 }
                              
                             },
                             error: function () {

                             },
                             cache: false
                 });
}
