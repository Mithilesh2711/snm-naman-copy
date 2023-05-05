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

function filter_city(){
  var useroot = $("#userXRoot").val();
  $("form#myforms").attr("action",useroot+"city/search");   
  $("form#myforms").submit();
}
function alertChecked(url){
  if( confirm("Are you sure want to delete ?")){
      window.location = url
  }
}



function print_others_register(){
          var usePath      = $.trim( $("#userXRoot").val() );
          var fromdated    = $.trim( $("#search_fromdated").val() );
          var uptodated    = $.trim( $("#search_uptodated").val() );
          var sedep        = $.trim( $("#sewadar_departments").val() );
          var sewcatg      = $.trim( $("#sewadar_categories").val() );
          var refecoename  = $.trim( $("#sewadar_codetype").val() );
          var sewsearches  = $.trim( $("#sewadar_string").val() );
          var requesttype  = $.trim( $("#sewdar_requesttype").val() );
          var printurl     = $.trim( $("#printexceled").attr("rel") );
          var chekexcel    = ""
          if( $("input[name='advance_detail']").is(":checked")){
              chekexcel = $("input[name='advance_detail']:checked").val();
          }
   
           $.ajax({
                       url: usePath+"advance_report/ajax_process",
                       type: 'POST',
                       data: {'fromdated': fromdated,'uptodated':uptodated,'sltype':chekexcel,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'requesttype':requesttype,'identity':'Y'},
                       async: false,
                       success: function (resp) {
                            if(resp.status){
                                window.open(usePath+printurl, '_blank');
                            }else{
                                alert("No record(s) found.");
                                return false;
                            }
                       },
                       error: function () {

                       },
                       cache: false
               });


}

$("#search_fromdated").click(function() {
     $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
  });
  $("#search_uptodated").click(function() {
     $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
  });