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

function filter_address(){
  var useroot = $("#userXRoot").val();
  $("form#myforms").attr("action",useroot+"address/search");   
  $("form#myforms").submit();
}
function alertChecked(url){
  if( confirm("Are you sure want to delete ?")){
      window.location = url
  }
}

function search_city(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var text  = $.trim( $("#search_city").val() );

    $.ajax({
        url: usePath+"address/ajax_process",
        type: 'POST',
        data: {'text': text,'identity':'SEARCHCITY','type':'SEARCHCITY'},
        async: false,
        success: function (resp) {
          var sdata = resp.data;
          var mhtml  = '<option value="">-Select-</option>';
          var i = 1;
         if(sdata.length >0 ){
                $.each(sdata,function(key,leds){
                    mhtml +='<option value="'+leds.ct_citycode+'">'+leds.ct_description+'</option>';
                    i++;
               });
         }
         $("#adr_city").html(mhtml);
        },
        error: function () {
            
        },
        cache: false
});


}

function get_city_by_district(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var statecode  = $.trim( $("#adr_state").val() );
    var districtcode  = $.trim( $("#adr_district").val() );

    $.ajax({
        url: usePath+"address/ajax_process",
        type: 'POST',
        data: {'statecode': statecode,'districtcode': districtcode,'identity':'CITY','type':'CITY'},
        async: false,
        success: function (resp) {
          var sdata = resp.data;
          var mhtml  = '<option value="">-Select-</option>';
          var i = 1;
         if(sdata.length >0 ){
                $.each(sdata,function(key,leds){
                    mhtml +='<option value="'+leds.ct_citycode+'">'+leds.ct_description+'</option>';
                    i++;
               });
         }
         $("#adr_city").html(mhtml);
        },
        error: function () {
            
        },
        cache: false
});


}

function get_district_by_state(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var statecode  = $.trim( $("#adr_state").val() );

     $.ajax({
                     url: usePath+"address/ajax_process",
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
                      $("#adr_district").html(mhtml);
                    //   $("#adr_city").html(chtm);

                     },
                     error: function () {
                         
                     },
                     cache: false
         });


}