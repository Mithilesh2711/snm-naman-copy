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

function filter_search(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"raw_punch/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
$("#mylocfrdate").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});
$("#mylocupdate").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});
function download_attendance(tabled, filename){
    var downloadurl;
    var fileType    = 'application/vnd.ms-excel';
     var tableSelect = document.getElementById(tabled);
     var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
     filename        = filename?filename+'.xls':'rawpunches_report.xls';
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
