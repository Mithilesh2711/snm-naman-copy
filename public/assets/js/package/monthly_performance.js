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
function printToExcel(tabled, filename){
    var downloadurl;
    var fileType    = 'application/vnd.ms-excel';
     var tableSelect = document.getElementById(tabled);
     var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
     filename        = filename?filename+'.xls':'performance_report.xls';
     downloadurl     = document.createElement("a");
     document.body.appendChild(downloadurl);

      if(navigator.msSaveOrOpenBlob){
                   var blob = new Blob(['\ufeff', dataHTML],{type:  fileType });
                   navigator.msSaveOrOpenBlob( blob, filename);
          }else
            {
                     downloadurl.href = 'data:' + fileType + ', ' + dataHTML;
                     downloadurl.download = filename;
                     downloadurl.click();
            }

}
function filter_monthly(){
    var useroot = $("#rootXPath").val();
    $("form#myforms").attr("action",useroot+"monthly_performance/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function get_districtcode_by_states(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var statecode  = $.trim( $("#ct_statecode").val() );

             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'statecode': statecode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.dts_districtcode+'">'+leds.dts_districtcode+'</option>';
                                         i++;
                                    });
                              }
                              $("#ct_districtcode").html(mhtml);
                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}