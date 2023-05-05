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

function filter_full_final(){
    var useroot = $("#rootXPath").val();
    $("form#myforms").attr("action",useroot+"full_final/search");
    $("form#myforms").submit();
}

function print_salary_excel_register(){
   
    var usePath      = $.trim( $("#userXRoot").val() );   
    var printurl     = $.trim( $("#printexceled").attr("rel") );
    var types        = $("input[name='ex_gratia']:checked").val();
    var sewacode     =  $.trim( $("#al_sewadarcode").val() );
    if( sewacode == '' ){
        alert("Please select sewadar name or code");
        $("#al_sewadarcode").focus();
        return false;
    }
     $.ajax({
                 url: usePath+"report_full_and_final/ajax_process",
                 type: 'POST',
                 data: {'sewacode':sewacode,'types':types,'identity':'Y'},
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



function set_common_focus(id){
    $("#"+id).focus();
}

function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );

             $.ajax({
                             url: usePath+"full_final/ajax_process",
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
function check_number_months(){
    var goldenhandshake = $.trim( $("#ff_goldenhandshake").val() ); 
    if( goldenhandshake != '' && parseFloat(goldenhandshake)>12 ){
        alert("Golden hand shake should not be greater than 12 months");
        $("#ff_goldenhandshake").val('');
        setTimeout(function(){ set_common_focus("ff_goldenhandshake");},500);
        return false;
    }
}
function reset_all_common_selected(){
    $("#ff_datejoing").val('');
    $("#ff_dob").val('');
    $("#ff_datesupan").val('');
    $("#ff_totalsewa").val('');
    $("#ff_totaladvance").val('');
    $("#ff_maintenancealw").val('');
    $("#ff_totalel").val(''); 
    $("#ff_prevsalary").val(''); 
    $("#ff_exgratiatued").val(''); 
    $("#ff_goldenhandshake").val(''); 
    $("#ff_datereguliazation").val(''); 
    $("#ff_vaccant").val(''); 
    $("#ff_leavingdate").val(''); 
    $("#ff_datereguliazation").val(''); 
    $("#ff_encashel").val(''); 
}

function fill_from_sewadar_listed(types){
            var usePath  = $.trim( $("#rootXPath").val() );
            var sewcode  = ""
            reset_all_common_selected();
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar' ){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            var catname  = '';
             var result  = '';
             var catcode = '';
             $.ajax({
                             url: usePath+"full_final/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code' ){
                                        $("#alsewdarname").val(sewcode);                                       
                                        $("#ff_datejoing").val(resp.data[0].joiningdate);
                                        $("#ff_dob").val(resp.data[0].dobs);
                                        $("#ff_datesupan").val(resp.data[0].superannualdate);
                                        $("#ff_totalsewa").val(resp.data[0].sewduration);
                                        $("#ff_totaladvance").val(resp.data[0].advanced);
                                        $("#ff_maintenancealw").val(resp.data[0].totalma);
                                        $("#ff_totalel").val(resp.data[0].leavebalances)
                                        $("#ff_vaccant").val(resp.data[0].accomodation);
                                        $("#ff_encashel").val(resp.data[0].elenashment);
                                        $("#ff_datereguliazation").val(resp.data[0].dateofreguliazation);
                                        
                                        
                                        
                                     }else if( types == 'sewadar' ){

                                        $("#al_sewadarcode").val(sewcode);
                                        $("#ff_datejoing").val(resp.data[0].joiningdate);
                                        $("#ff_dob").val(resp.data[0].dobs);
                                        $("#ff_datesupan").val(resp.data[0].superannualdate);
                                        $("#ff_totalsewa").val(resp.data[0].sewduration);
                                        $("#ff_totaladvance").val(resp.data[0].advanced);
                                        $("#ff_maintenancealw").val(resp.data[0].totalma);
                                        $("#ff_totalel").val(resp.data[0].leavebalances);
                                        $("#ff_vaccant").val(resp.data[0].accomodation);
                                        $("#ff_encashel").val(resp.data[0].elenashment);
                                        $("#ff_datereguliazation").val(resp.data[0].dateofreguliazation);
                                        
                                     }
                                 }else{
                                    $("#ff_datejoing").val('');
                                    $("#ff_dob").val('');
                                    $("#ff_datesupan").val('');
                                    $("#ff_totalsewa").val('');
                                    $("#ff_totaladvance").val('');
                                    $("#ff_maintenancealw").val('');
                                    $("#ff_totalel").val(''); 
                                    $("#ff_prevsalary").val(''); 
                                    $("#ff_exgratiatued").val(''); 
                                    $("#ff_goldenhandshake").val(''); 
                                    $("#ff_datereguliazation").val(''); 
                                    $("#ff_vaccant").val(''); 
                                    $("#ff_leavingdate").val(''); 
                                    $("#ff_datereguliazation").val(''); 
                                    $("#ff_encashel").val('');                                      
                                   alert("No record(s) found.");
                                 }


                             },
                             error: function () {
                                $("#ff_datejoing").val('');
                                $("#ff_dob").val('');
                                $("#ff_datesupan").val('');
                                $("#ff_totalsewa").val('');
                                $("#ff_totaladvance").val('');
                                $("#ff_maintenancealw").val('');
                                $("#ff_totalel").val('');  
                                $("#ff_prevsalary").val(''); 
                                $("#ff_exgratiatued").val(''); 
                                $("#ff_goldenhandshake").val(''); 
                                $("#ff_datereguliazation").val(''); 
                                $("#ff_vaccant").val(''); 
                                $("#ff_leavingdate").val('');  
                                $("#ff_datereguliazation").val(''); 
                                $("#ff_encashel").val('');  
                             },
                             cache: false
                 });
}
$("#ff_leavingdate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy",onSelect:function(evt){ setTimeout(function(){ calculate_grtia();},500);} }).datepick("show");
});

 $("#ff_fullandfinaldate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });