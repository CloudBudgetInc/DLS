({
	selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectObject = component.get("v.obj");
    // call the event   
      var compEvent = component.getEvent("getSelectedElementEvent");
    // set the Selected sObject Record to the event attribute.  
        var type = component.get('v.type');
        if(type && type != ''){
        compEvent.setParams({
            "objectByEvent" : getSelectObject,
            "type" : type
        });  
        } else {
        compEvent.setParams({"objectByEvent" : getSelectObject });  
        }
    // fire the event  
         compEvent.fire();
    },
})