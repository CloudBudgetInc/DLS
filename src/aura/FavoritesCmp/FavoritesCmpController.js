({
	doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        const action = cmp.get('c.getFavoriteMaterialsInfo');
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
                console.log('error',errors);
                cmp.set("v.showSpinner",false);
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
        var favoriteSection = cmp.find("favoriteSection");
        console.log('::::::::favoriteSection:::',favoriteSection);
        $A.util.addClass(favoriteSection, 'slds-hide');
    },
    backFromDetailPage : function(cmp, event ,helper){
        if(cmp.get("v.displayfavoriteSection")){
            var favoriteSection = cmp.find("favoriteSection");
            $A.util.removeClass(favoriteSection, 'slds-hide');
            cmp.set("v.displayMaterialDetail",false);
            cmp.set("v.displayfavoriteSection",false);
        }
    },
    backToHomePage : function(cmp, event, helper){
        cmp.set("v.displaySearchResult",true);
    }
})