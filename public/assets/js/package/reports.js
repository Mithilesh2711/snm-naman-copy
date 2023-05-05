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

function print_salary_slip(){
            var usePath      = $.trim( $("#userXRoot").val() );
            var years        = $.trim( $("#hph_years").val() );
            var months       = $.trim( $("#hph_months").val() );
            var sedep        = $.trim( $("#sewadar_departments").val() );
            var sewcatg      = $.trim( $("#sewadar_categories").val() );
            var refecoename  = $.trim( $("#sewadar_codetype").val() );
            var sewsearches  = $.trim( $("#sewadar_string").val() );
            var bankname     = $.trim( $("#sewadar_bankname").val() );

            var printurl     = $.trim( $("#printexceled").attr("rel") );
            var printtype    = "";
            if( $("input[name='print_type']").is(":checked") ){
                printtype = $("input[name='print_type']:checked").val();
            }
            if( years == '' ){
                alert("Year is required.");
                $("#hph_years").focus();
                return false;
            }else if( months == '' ){
                alert("Month is required.");
                $("#hph_months").focus();
                return false;
            }
            if(  printtype !='' && printtype =='BK' ) {
                if( bankname == '' ){
                    alert("Please select bank.");
                    return false;
                }
            }

            $(".printedprocess").hide();
          
             $.ajax({
                         url: usePath+"reports/ajax_process",
                         type: 'POST',
                         data: {'printtype' : printtype,'bankname':bankname,'years': years,'months':months,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'identity':'Y'},
                         async: false,
                         success: function (resp) {
                            $(".printedprocess").show();
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

function print_salary_excel_register(){
            var usePath      = $.trim( $("#userXRoot").val() );
            var years        = $.trim( $("#hph_years").val() );
            var months       = $.trim( $("#hph_months").val() );
            var sedep        = $.trim( $("#sewadar_departments").val() );
            var sewcatg      = $.trim( $("#sewadar_categories").val() );
            var refecoename  = $.trim( $("#sewadar_codetype").val() );
            var sewsearches  = $.trim( $("#sewadar_string").val() );
            var printurl     = $.trim( $("#printmyexceled").attr("rel") );
            var bankname     = $.trim( $("#sewadar_bankname").val() );
            var printtype    = "";
            if( $("input[name='print_type']").is(":checked") ){
                printtype = $("input[name='print_type']:checked").val();
            }
            if( years == ''){
                alert("Year is required.");
                return false;
            }
            if( months == ''){
                alert("Month is required.");
                return false;
            }
            if(  printtype !='' && printtype =='BK' ) {
                if( bankname == '' ){
                    alert("Please select bank.");
                    return false;
                }
            }

            $(".printedprocess").hide();
             $.ajax({
                         url: usePath+"reports/ajax_process",
                         type: 'POST',
                         data: { 'printtype' : printtype,'bankname':bankname,'years': years,'months':months,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'identity':'Y'},
                         async: false,
                         success: function (resp) {
                            $(".printedprocess").show();
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
function print_others_register(){
            var usePath      = $.trim( $("#userXRoot").val() );
            var years        = $.trim( $("#hph_years").val() );
            var months       = $.trim( $("#hph_months").val() );
            var sedep        = $.trim( $("#sewadar_departments").val() );
            var sewcatg      = $.trim( $("#sewadar_categories").val() );
            var refecoename  = $.trim( $("#sewadar_codetype").val() );
            var sewsearches  = $.trim( $("#sewadar_string").val() );
            var printurl     = $.trim( $("#printexceled").attr("rel") );
            var chekexcel    = ""
            if( $("input[name='monthly_deduction']").is(":checked")){
                chekexcel = $("input[name='monthly_deduction']:checked").val();
            }
            if( years == '' ){
                alert("Year is required");
                $("#hph_years").focus() 
                return false;
            }else if( months == '' ){
                alert("Month is required");
                $("#hph_months").focus() 
                return false;
            }
           
             $.ajax({
                         url: usePath+"reports/ajax_process",
                         type: 'POST',
                         data: {'years': years,'months':months,'sltype':chekexcel,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'identity':'Y'},
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
function print_daily_reports(){
    var usePath      = $.trim( $("#rootXPath").val() );
    var from_date    = $.trim( $("#from_date").val() );
    var department   = $.trim( $("#emp_department").val() );
    var location     = $.trim( $("#emp_location").val() );
    var empcodes     = $.trim( $("#empcodes").val() );   
    var printurl     = $.trim( $("#printexceled").attr("rel") );
    var types        = ""
    if( $("input[name='process_type']").is(":checked") ){
        types = $.trim( $("input[name='process_type']:checked").val() );
    }
 
     $.ajax({
                 url: usePath+"reports/ajax_process",
                 type: 'POST',
                 data: {'types':types,'from_date': from_date,'upto_date':'','department':department,'location':location,'empcodes':empcodes,'identity':'DAILYRPT'},
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