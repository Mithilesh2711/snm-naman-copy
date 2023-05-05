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

function print_bakshis_sewa(){
            var usePath  = $.trim( $("#userXRoot").val() );
           if( confirm("Are you sure want to process this?")){
               $(".selectedprocess").removeClass("hidden");
               $(".calculatebttnprocess").removeClass("hidden").addClass("hidden");
                    $.ajax({
                                url: usePath+"samagam_bakshis/ajax_process",
                                type: 'POST',
                                data: {'identity':'Y'},
                                async: false,
                                success: function (resp) {
                                    $(".selectedprocess").removeClass("hidden").addClass("hidden");
                                    $(".calculatebttnprocess").removeClass("hidden");

                                    if(resp.status){
                                       alert(resp.message);
                                       return false;
                                    }else{
                                        alert("could not be processed due to technical issue.");
                                        return false;
                                    }
                                },
                                error: function () {
                                    $(".selectedprocess").removeClass("hidden").addClass("hidden");
                                    $(".calculatebttnprocess").removeClass("hidden");
                                },
                                cache: false
                        });

         }

    
}

function print_salary_slip(){
        var usePath   = $.trim( $("#userXRoot").val() );   
        var printurl  = $.trim( $("#printexceled").attr("rel") ); 
        var  bankurl  = $.trim( $("#bankreports").val() ); 
        var  depturl  = $.trim( $("#departmentwisereports").val() ); 
        chekedval     = ""
        if( $("input[name='print_type']").is(":checked") ){
                var chekedval = $("input[name='print_type']:checked").val();
        }
        if( chekedval == 'BANK' ){
            printurl = bankurl
        } else if( chekedval == 'DEPARTMENT' ){
            printurl = depturl
        }
    
             $.ajax({
                         url: usePath+"samagam_bakshis/ajax_process",
                         type: 'POST',
                         data: {'identity':'RPT'},
                         async: false,
                         success: function (resp) {
                               if( resp.status ){
                                    window.open(usePath+printurl, '_blank');
                                }else{
                                    alert("No record(s) found.");
                                    return false;
                                }
                         },
                         error: function () {
                             $(".selectedprocess").removeClass("hidden").addClass("hidden");
                             $(".calculatebttnprocess").removeClass("hidden");
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