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


function get_monthly_deduction(){
    var usePath      = $.trim( $("#rootXPath").val() );    
    var dateleaving  = $.trim( $("#ff_leavingdate").val() );
    var empcode      = $.trim( $("#al_sewadarcode").val() );
     $.ajax({
                     url: usePath+"full_final/ajax_process",
                     type: 'POST',
                     data: {'identity':'PMDATA','empcode': empcode,'leavingdate' : dateleaving},
                     async: false,
                     success: function (resp) {
                        if( resp.status){
                            var sdata = resp.data;
                            $("#ff_deductfirst").val(sdata.pm_dedfirst);
                            $("#ff_deductfirstrmk").val(sdata.pm_dedremarkfirst);
                            $("#ff_deductsecond").val(sdata.pm_dedsecond);
                            $("#ff_deductsecrmk").val(sdata.pm_dedremarksecond);
                        }
                          
                     },
                     error: function () {

                     },
                     cache: false
         });


}


function calculate_grtia(){
    var usePath  = $.trim( $("#rootXPath").val() );
    var dtofjoining  = $.trim( $("#ff_datejoing").val() );
    var dateleaving  = $.trim( $("#ff_leavingdate").val() );
    var dtereguliza  = $.trim( $("#ff_datereguliazation").val() );
    var maamount     = $.trim( $("#ff_maintenancealw").val() );
    var elbal        = $.trim( $("#ff_totalel").val() );
    var dedcuctfirst = $.trim( $("#ff_deductfirst").val() );
    var sewcode      = $.trim( $("#al_sewadarcode").val() ); 

     $.ajax({
                     url: usePath+"full_final/ajax_process",
                     type: 'POST',
                     data: {'identity':'GRAT','sewcode':sewcode,'maamount':maamount,'elbal':elbal,'dtofjoining':dtofjoining,'dateleaving':dateleaving,'dtereguliza':dtereguliza},
                     async: false,
                     success: function (resp) {
                        // if( resp.graiatiaz  != '' ){
                        //     $("#ff_exgratiatued").val(resp.graiatiaz)
                        // }else{
                        //     $("#ff_exgratiatued").val('')
                        // }
                        if( resp.gratiaamont != '' ) {
                            $("#ff_gratiaamount").val(resp.gratiaamont);
                        }else{
                            $("#ff_gratiaamount").val('');
                        }
                        
                          
                     },
                     error: function () {

                     },
                     cache: false
         });
         if ( dedcuctfirst == '' ){
            setTimeout(function(){ get_monthly_deduction();},500);
         }
         

}

function set_common_focus(id){
    $("#"+id).focus();
}

function find_total_service_after_leaving(){
    var usePath     = $.trim( $("#rootXPath").val() );
    var leavingdate = $.trim( $("#ff_leavingdate").val() );
    var sewcode     = $.trim( $("#al_sewadarcode").val() );   

     $.ajax({
                     url: usePath+"full_final/ajax_process",
                     type: 'POST',
                     data: {'leavingdate': leavingdate,'sewcode':sewcode,'identity':'TOTSERVICE'},
                     async: false,
                     success: function (resp) {
                            if( resp.status ){
                                $("#ff_totalsewa").val(resp.data);
                                $("#ff_beforelwmtotalsewa").val(resp.beforelwmdate);
                                $("#ff_totallwm").val(resp.lwm);
                            }else{
                                $("#ff_totalsewa").val('');
                                $("#ff_beforelwmtotalsewa").val('');
                                $("#ff_totallwm").val('');
                            }
                            setTimeout(function(){ calculate_grtia();},500);
                     },
                     error: function () {
                        $("#ff_totalsewa").val('');
                        $("#ff_beforelwmtotalsewa").val('');
                        $("#ff_totallwm").val('');
                     },
                     cache: false
         });


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

                                     $.each(sdata,function(key,led){
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
            var leavingdate = $.trim( $("#ff_leavingdate").val() );
            reset_all_common_selected();
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar' ){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            
             $.ajax({
                             url: usePath+"full_final/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'leavingdate':leavingdate,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code' ){
                                        if( resp.data[0].sw_leavingdate !='' && resp.data[0].sw_leavingdate !=null ){
                                            alert("This sewadar is already applied");
                                            return false;
                                         }
                                        $("#alsewdarname").val(sewcode);                                       
                                        $("#ff_datejoing").val(resp.data[0].joiningdate);
                                        $("#ff_dob").val(resp.data[0].dobs);
                                        $("#ff_datesupan").val(resp.data[0].superannualdate);
                                       // $("#ff_totalsewa").val(resp.data[0].sewduration);
                                        $("#ff_totaladvance").val(resp.data[0].advanced);
                                        $("#ff_maintenancealw").val(resp.data[0].totalma);
                                        $("#ff_totalel").val(resp.data[0].leavebalances)
                                        $("#ff_vaccant").val(resp.data[0].accomodation);
                                        $("#ff_encashel").val(resp.data[0].elenashment);
                                        $("#ff_datereguliazation").val(resp.data[0].dateofreguliazation);                                    
                                        $("#ff_exgratiatued").val(resp.data[0].exgamount); 
                                        
                                        
                                     }else if( types == 'sewadar' ){
                                        if( resp.data[0].sw_leavingdate !='' && resp.data[0].sw_leavingdate !=null ){
                                            alert("This sewadar is already applied");
                                            return false;
                                         }
                                        $("#al_sewadarcode").val(sewcode);
                                        $("#ff_datejoing").val(resp.data[0].joiningdate);
                                        $("#ff_dob").val(resp.data[0].dobs);
                                        $("#ff_datesupan").val(resp.data[0].superannualdate);
                                       // $("#ff_totalsewa").val(resp.data[0].sewduration);
                                        $("#ff_totaladvance").val(resp.data[0].advanced);
                                        $("#ff_maintenancealw").val(resp.data[0].totalma);
                                        $("#ff_totalel").val(resp.data[0].leavebalances);
                                        $("#ff_vaccant").val(resp.data[0].accomodation);
                                        $("#ff_encashel").val(resp.data[0].elenashment);
                                        $("#ff_datereguliazation").val(resp.data[0].dateofreguliazation);
                                        $("#ff_exgratiatued").val(resp.data[0].exgamount); 
                                        
                                     }
                                 }else{
                                    $("#ff_datejoing").val('');
                                    $("#ff_dob").val('');
                                    $("#ff_datesupan").val('');
                                    //$("#ff_totalsewa").val('');
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
                                    $("#ff_exgratiatued").val('');                                    
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
        setTimeout(function(){ get_monthly_deduction();},500);
}
$("#ff_leavingdate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy",onSelect:function(evt){ setTimeout(function(){ find_total_service_after_leaving();},500);} }).datepick("show");
});

 $("#ff_fullandfinaldate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });