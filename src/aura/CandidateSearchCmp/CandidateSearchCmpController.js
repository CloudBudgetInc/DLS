({
    doinit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getFilterInformations(component);
        component.set("v.displayFiltersection",true);
    },
    hideFilter: function(component, event, helper){
        var displayFilter = component.get("v.displayFiltersection");
        component.set("v.displayFiltersection",!displayFilter);
    },
    searchClick: function(component, event, helper){
        component.set("v.showSpinner",true);
        console.log('enter searchclick');
        helper.getFilteredContacts(component);
    },
    closeClickOnInfo: function(component, event, helper){
        component.set("v.showInfoWindow",false);
    },
    tableActionHandler: function(component, event, helper){
        var actionId = event.getParam('actionId');
        var instructor = event.getParam('row');
        if(actionId == 'moreClick'){
            // Open more info related modal
            component.set("v.showSpinner",true);
            helper.displayMoreInfoDetails(component,instructor);
        }else if(actionId == 'bookMark'){
            // display bookmark creation
            helper.bookMarkDetails(component,instructor);
        }
    },
    handleLookupEvent: function(component, event, helper){
        var selectedobj = event.getParam("objectByEvent");
        var type = event.getParam("type");
        var search = component.get("v.search");
        if(type == 'Location'){
            search.selectedlocation = selectedobj;
        }else {
            search.selectedBookmark = selectedobj;
        }
        component.set("v.search",search);
    },
    locationZipFlip: function(component, event, helper){
        component.set("v.displayZip",!component.get("v.displayZip"));
    },
    closeClickOnMoreInfo: function(component, event, helper){
        component.set("v.displayMoreInfoModal",false);
    },
    bookMarkModalClose: function(component, event, helper){
        component.set("v.displayBookMarkSection",false);
    },
    lookupSearch : function(component, event, helper) {
        console.log('entrer lookup search');
        // Get the getLookupRecords server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    },
    locationLookupSearch : function(component, event, helper){
        // Get the SampleLookupController.search server side action
        console.log('location lookup search');
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('locationLookup').search(serverSearchAction);
    }
    
    
})