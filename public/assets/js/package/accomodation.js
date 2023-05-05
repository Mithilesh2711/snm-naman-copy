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

function filter_accomodation(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"accomodation/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function checked_belogs_values(objval){
   $("#ad_belongs").val(objval);
}
function get_districtcode_by_states(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var statecode  = $.trim( $("#ad_state").val() );

             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'statecode': statecode,'identity':'DIST','type':'DIST'},
                             async: false,
                             success: function (resp) {
                               var sdata  = resp.data;
                               var cdata  = resp.cities;
                               var mhtml  = '<option value="">-Select-</option>';
                               var chtm   = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.dts_districtcode+'">'+leds.dts_description+'</option>';
                                         i++;
                                    });
                              }
                              if(cdata.length >0 ){
                                     $.each(cdata,function(key,led){
                                         chtm +='<option value="'+led.ct_citycode+'">'+led.ct_description+'</option>';
                                         i++;
                                    });
                              }
                              $("#ad_district").html(mhtml);
                              $("#ad_city").html(chtm);

                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}
function pickup_accomodation_value(){
    var textvl       =  $.trim( $("#ad_accomodtype option:selected").text() );
    var prevsdescrip =  "";
    if( textvl != '-Select-' ){
       prevsdescrip =  textvl
    }
    $("#at_description").val(prevsdescrip);
}
function process_reset_accomodationtype(){
        $("#at_description").val("");
        $("#ad_accomodtype").val("");
       
}

function process_add_accomodationtype(){
            var usePath      = $.trim( $("#rootXPath").val() );
            var description  = $.trim( $("#at_description").val() );
            var mid          = $.trim( $("#ad_accomodtype option:selected").val() );
            var curtext      = $.trim( $("#ad_accomodtype option:selected").text() );
            var prevsdescrip = "";
            if( curtext != '-Select-' ){
               prevsdescrip =  curtext
            }
            if( description == '' ){
                alert("Please enter name");
                return false;
            }
            $(".process_popupsave").hide();
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'description': description,'prevsdescrip':prevsdescrip,'identity':'ADDACOT','mid':mid},
                             async: false,
                             success: function (resp) {                                                         
                               var mhtml  = '<option value="">-Select-</option>';
                               alert(resp.message);
                               if ( resp.status){
                                        var i      = 1;
                                        var sdata  = resp.data;   
                                      if(sdata.length >0 ){
                                             $.each(sdata,function(key,leds){
                                                 var isselected = "";
                                                 if( leds.at_description.toLowerCase() == description.toLowerCase() ){
                                                     isselected ='selected="selected"';
                                                 }
                                                 mhtml +='<option value="'+leds.id+'" '+isselected+'>'+leds.at_description+'</option>';
                                                 i++;
                                            });
                                      }

                               }
                               $("#at_description").val("");
                               $("#ad_accomodtype").html(mhtml);
                               $(".process_popupsave").show();
                               $("#add_type").modal("hide");

                             },
                             error: function () {
                                $("#ad_accomodtype").html('<option value="">-Select-</option>');
                                $(".process_popupsave").show();
                             },
                             cache: false
                 });


}

function process_delete_accomodation_type(){
         var usePath      = $.trim( $("#rootXPath").val() );
            var description  = $.trim( $("#at_description").val() );
            var mid          = $.trim( $("#ad_accomodtype option:selected").val() );
            
            if( mid <=0 ){
                alert("Please select accomodation type");
                return false;
            }
            if( confirm("Are you sure want to delete this ?")){
            $(".process_popupsave").hide();
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'identity':'DELACCD','mid':mid},
                             async: false,
                             success: function (resp) {
                               var mhtml  = '<option value="">-Select-</option>';
                               alert(resp.message);
                               if ( resp.status){
                                        var i      = 1;
                                        var sdata  = resp.data;
                                      if(sdata.length >0 ){
                                             $.each(sdata,function(key,leds){
                                                 var isselected = "";
                                                 if( leds.at_description.toLowerCase() == description.toLowerCase() ){
                                                     isselected ='selected="selected"';
                                                 }
                                                 mhtml +='<option value="'+leds.id+'" '+isselected+'>'+leds.at_description+'</option>';
                                                 i++;
                                            });
                                      }
                                      $("#ad_accomodtype").html(mhtml);
                               }
                               $("#at_description").val("");                               
                               $(".process_popupsave").show();
                               $("#add_type").modal("hide");

                             },
                             error: function () {
                                $("#ad_accomodtype").html('<option value="">-Select-</option>');
                                $(".process_popupsave").show();
                             },
                             cache: false
                 });

            }
}