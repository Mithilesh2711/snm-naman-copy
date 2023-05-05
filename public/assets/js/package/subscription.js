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

function filter_subscription(){
  var useroot = $("#userXRoot").val();
  $("form#myforms").attr("action",useroot+"subscription/search");   
  $("form#myforms").submit();
}
function alertChecked(url){
  if( confirm("Are you sure want to delete ?")){
      window.location = url
  }
}


function handle_subscription_amount(){
    var usePath    = $.trim( $("#rootXPath").val() );
    
    var mag  = $.trim( $("#sub_magazine").val() );
    var subtyp  = $.trim( $("#sub_subtyp").val() );
    var cur  = $.trim( $("#sub_currency").val() );
    var quant = $.trim( $("#sub_quantity").val() );

    $.ajax({
        url: usePath+"subscription/ajax_process",
        type: 'POST',
        data: {'mag': mag,'subtyp': subtyp,'cur': cur,'identity':'AMOUNT','type':'AMOUNT'},
        async: false,
        success: function (resp) {
          var sdata = resp.data;
          $("#sub_amount").val(parseFloat(sdata)*parseInt(quant));
        },
        error: function () {
            
        },
        cache: false
});


}

function get_dispatchto_by_type(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var dispatchType  = $.trim( $("#sub_dispatchtype").val() );
    var member  = $.trim( $("#sub_member").val() );

    $.ajax({
        url: usePath+"subscription/ajax_process",
        type: 'POST',
        data: {'member':member,'dispatchType': dispatchType,'identity':'DISPATCHTO','type':'DISPATCHTO'},
        async: false,
        success: function (resp) {
            console.log(resp);
          var sdata = resp.data;
          var dtval = resp.dtval;
          var mhtml  = '<option value="">-Select-</option>';
          var i = 1;
         if(sdata.length >0 ){
                if(dtval === "Personal"){
                    $.each(sdata,function(key,leds){
                        mhtml +='<option value="'+leds.adr_code+'">'+leds.adr_fulladdress+'</option>';
                        i++;
                   });
                }
                else if(dtval === "Individual"){
                    $.each(sdata,function(key,leds){
                        mhtml +='<option value="'+leds.ih_code+'">'+leds.ih_address+'</option>';
                        i++;
                   });
                }
                else if(dtval === "Branch"){
                    $.each(sdata,function(key,leds){
                        mhtml +='<option value="'+leds.bch_branchcode+'">'+leds.bch_address+'</option>';
                        i++;
                   });
                }
                
         }
         $("#sub_dispatchto").html(mhtml);
        },
        error: function () {
            
        },
        cache: false
});


}
