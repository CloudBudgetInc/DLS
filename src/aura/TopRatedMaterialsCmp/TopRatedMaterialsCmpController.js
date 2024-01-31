({
	doinit : function(cmp, event, helper) {
		const server = cmp.find('server');
        const action = cmp.get('c.getTopRatedMaterialsInfo');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                console.log('favorites::update:',response);
                cmp.set("v.materials",response);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                helper.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	},
    redirectToMaterialDetail : function(cmp, event, helper){
        console.log(':::::::material::Id::',event.currentTarget.getAttribute("data-value"));
        var recordId = event.currentTarget.getAttribute("data-value");
        cmp.set("v.selectedRecordId",recordId);
        
        cmp.set("v.displayMaterialDetail",true);
        var topRatedSection = cmp.find("topRatedSection");
        console.log('::::::::topRatedSection:::',topRatedSection);
        $A.util.addClass(topRatedSection, 'slds-hide');
    },
    backFromDetailPage : function(cmp, event ,helper){
        if(cmp.get("v.displayTopRatedSection")){
            var topRatedSection = cmp.find("topRatedSection");
            $A.util.removeClass(topRatedSection, 'slds-hide');
            cmp.set("v.displayMaterialDetail",false);
            cmp.set("v.displayTopRatedSection",false);
        }
    },
    backToHomePage : function(cmp, event, helper){
        cmp.set("v.displaySearchResult",true);
    },
    
})