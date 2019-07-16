({
	handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //set action to call updatePicturePath method from Server-side controller
        var action = component.get("c.updatePicturePath");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
        	if(a.getState() === "SUCCESS"){
            	var resultToast = $A.get("e.force:showToast");
        		resultToast.setParams({
                    "type":"info",
                            "message": "Se cargó exitosamente el archivo"
                        });
        		resultToast.fire();;
                $A.get("e.force:refreshView").fire();
        	}
        });
    	$A.enqueueAction(action);
    }
})