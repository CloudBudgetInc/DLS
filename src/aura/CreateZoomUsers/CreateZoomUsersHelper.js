({
	showModal : function(component, title, msg) {
		
        component.set("v.successMsg", msg);
        component.set("v.successTitle",title);
        
        if(Array.isArray(component.find("successModal"))) {
            component.find("successModal")[0].open();
        }else{
            component.find("successModal").open();
        }                    
	}
})