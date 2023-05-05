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

function print_salary_excel_register(){
   
    var usePath      = $.trim( $("#userXRoot").val() );
    var years        = '';
    var months       = '';
    var sedep        = $.trim( $("#al_depcode").val() );
    var sewcatg      = '';
    var refecoename  = '';
    var sewsearches  = '';
    var printurl     = $.trim( $("#printexceled").attr("rel") );
    var types        = $("input[name='monthly_deduction']:checked").val();
    var sewacode     = $.trim( $("#alsewdarname").val() );
    var fromdate     = $.trim( $("#fromdate").val() );
    var uptodate     = $.trim( $("#uptodate").val() );
    if( sewacode == ''){
        alert("Please select sewadar name or code");
        $("#alsewdarname").focus();
        return false;
    }
     $.ajax({
                 url: usePath+"periodicreport/ajax_process",
                 type: 'POST',
                 data: {'sewacode':sewacode,'fromdate':fromdate,'uptodate':uptodate,'years': years,'months':months,'types':types,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'identity':'Y'},
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


function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );

             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'depcode': depcode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var vdata = resp.sedarname
                               var mhtml  = '<option value="">-Select-</option>';
                               var vhtml  = '<option value="">-Select-</option>';

                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+'</option>';
                                         i++;
                                    });

                                     $.each(vdata,function(key,led){
                                         vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+'</option>';

                                    });
                              }
                               $("#al_sewadarcode").html(mhtml);
                               $("#alsewdarname").html(vhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}
$("#fromdate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });

 $("#uptodate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });

function fill_from_sewadar_listed(types){
            var usePath  = $.trim( $("#rootXPath").val() );
            var sewcode  = ""
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar'){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            var catname  = '';
             var result  = '';
             var catcode = '';
             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code'){
                                        $("#alsewdarname").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $("#ls_referencecode").val(resp.data[0].sw_oldsewdarcode);                                         
                                         catcode = resp.data[0].sw_catcode;
                                        $("#ls_category").val(catcode);
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                     }else if( types == 'sewadar'){
                                        $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                        $("#ls_referencecode").val(resp.data[0].sw_oldsewdarcode);
                                        catcode = resp.data[0].sw_catcode;                                        
                                        $("#ls_category").val(catcode);
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                        
                                     }
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#ls_referencecode").val('');
                                        setTimeout(function(){ get_leave_types(); },500);
                                        setTimeout(function(){ clear_all_selected_leave_rules(); },500);
                                        alert("No record(s) found.");
                                 }


                             },
                             error: function () {
                                       $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        $("#ls_referencecode").val('');
                             },
                             cache: false
                 });
}