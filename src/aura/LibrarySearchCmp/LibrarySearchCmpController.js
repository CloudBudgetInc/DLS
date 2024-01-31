({
    doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        
        helper.setInitialValues(cmp);
        helper.getCurrentUserInfo(cmp,event);
        helper.getInitialFilterValues(cmp,event);
        
        if(device == 'PHONE'){
            var displayObj = cmp.get("v.displayObj");
            displayObj.searchEnabled = true;
            cmp.set("v.displayObj",displayObj);
            cmp.set("v.showSpinner",true);
            helper.getSearchInputs(cmp, event);
        }
    },
    searchMaterials : function(cmp, event, helper){
        var displayObj = cmp.get("v.displayObj");
        var filterObj = cmp.get("v.filterObj");
        filterObj.pageNumber = 1;
        displayObj.searchEnabled = true;
        cmp.set("v.displayObj",displayObj);
        cmp.set("v.filterObj",filterObj);
        cmp.set("v.showSpinner",true);

        helper.getSearchInputs(cmp, event);
    },
    onEnterSearchMaterials : function(cmp, event, helper){
        if(event.keyCode == 13) {
            cmp.set("v.showSpinner",true);
            var displayObj = cmp.get("v.displayObj");
            displayObj.searchEnabled = true;
            cmp.set("v.displayObj",displayObj);
            
            helper.getSearchInputs(cmp, event);
        }
    },
    lookupLanguageSearch : function(cmp, event, helper){
        console.log('search');
        const serverSearchAction = cmp.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    },
    clearFilter : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var displayObj = cmp.get("v.displayObj");
        var displayDevice = cmp.get("v.displayDevice")
        displayObj.searchEnabled = false;
        displayObj.displaySearchResult = false;
        displayObj.materialRecordsCnt = 0;
        displayObj.materialTotalCol1 = 0;
        displayObj.materialTotalCol2 = 0;
        
        if(displayDevice == 'Mobile'){
            var displayObj = cmp.get("v.displayObj");
            displayObj.searchEnabled = true;
            cmp.set("v.showSpinner",true);
            helper.getSearchInputs(cmp, event);
        }
        
        cmp.set("v.displayContents",[]);
        cmp.set("v.displayMaterials",[]);
        
        helper.setInitialValues(cmp);
        helper.getInitialFilterValues(cmp,event);
        
        if(displayDevice == 'Mobile'){
            var displayObj = cmp.get("v.displayObj");
            displayObj.searchEnabled = true;
            cmp.set("v.showSpinner",true);
            helper.getSearchInputs(cmp, event);
        }
        cmp.set("v.displayObj",displayObj);
        
        var showMobileViewFilterModel = cmp.get("v.showMobileViewFilterModel");
        if(showMobileViewFilterModel){
            cmp.set("v.tabName","searchInfo");
            cmp.set("v.showMobileViewFilterModel",false);
        }
    },
    redirectToContentDetail : function(cmp, event, helper){
        console.log(":::content::Id::::",event.currentTarget.getAttribute("data-value"));
        var recordId = event.currentTarget.getAttribute("data-value");
        cmp.set("v.selectedRecordId",recordId);
        
        cmp.set("v.displayContentDetail",true);
        var searchCard = cmp.find("searchCard");
        $A.util.addClass(searchCard, 'slds-hide');
        
        /*if(cmp.get("v.userType") == 'Internal'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ContentDetailCmp",
                componentAttributes: {
                    filterObj : cmp.get("v.filterObj"),
                    recordId : recordId,
                    userType : cmp.get("v.userType")
                }
            });
            evt.fire();
        }*/
    },
    redirectToMaterialDetail : function(cmp, event, helper){
        console.log(':::::::material::Id::',event.currentTarget.getAttribute("data-value"));
        var recordId = event.currentTarget.getAttribute("data-value");
        cmp.set("v.selectedRecordId",recordId);
        
        cmp.set("v.displayMaterialDetail",true);
        var searchCard = cmp.find("searchCard");
        console.log('::::::::searchCard:::',searchCard);
        $A.util.addClass(searchCard, 'slds-hide');
        
    },
    BackFromDetailPage : function(cmp, event, helper){
        console.log('enter BackFromDetailPage');
        
        if(cmp.get("v.displaySearchResult")){
            cmp.set("v.displayMaterialDetail",false);
            cmp.set("v.displayContentDetail",false);
            
            //For Favorite Cmp
            cmp.set("v.displayFavoriteDetails",false);
            //For Top Rated Cmp
            cmp.set("v.displayTopRatedDetails",false);
            
            var searchCard = cmp.find("searchCard");
            $A.util.removeClass(searchCard, 'slds-hide');
            cmp.set("v.displaySearchResult",false);
        }
        
    },
    redirectToDetailFromHomePage : function(cmp, event, helper){
        var type = event.getParam("typeOfAction");
        
        if(type == 'HardCopy'){
            var recordId = event.getParam("recordId");
            cmp.set("v.selectedRecordId",recordId);
            cmp.set("v.displayMaterialDetail",true);
        }else if(type == 'Favorite'){
            cmp.set("v.displayFavoriteDetails",true);
        }else if(type == 'Top Rated'){
            cmp.set("v.displayTopRatedDetails",true);
        }
        
        var searchCard = cmp.find("searchCard");
        console.log('::::::::searchCard:::',searchCard);
        $A.util.addClass(searchCard, 'slds-hide');
    },
    searchTabClick : function(cmp ,event,helper){
        cmp.set("v.tabName",'searchInfo');
    }, 
    myMaterialTabClick : function(cmp ,event,helper){
        cmp.set("v.tabName",'myMaterials');
        cmp.set("v.showSpinner",true);
        
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.showSpinner",false);
            }), 3000);
    },
    avgRatingChange : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        if(cmp.get("v.filterObj").seletedRating != 'All'){
        	helper.filterMaterialsByRating(cmp);    
        }else {
            cmp.set("v.displayMaterials",cmp.get("v.wholeMaterials"));
            cmp.set("v.showSpinner",false);
        }
    },
    dateRangeChange : function(cmp, event,helper){
        cmp.set("v.showSpinner",true);
        if(cmp.get("v.filterObj").dateRangeSelected != 'All'){
        	helper.filterMaterialsByDateRange(cmp);    
        }else {
            cmp.set("v.displayMaterials",cmp.get("v.wholeMaterials"));
            cmp.set("v.showSpinner",false);
        }
    },
    openMobileFilterModal : function(cmp, event, helper){
        cmp.set("v.showMobileViewFilterModel",true);
        cmp.find("mobileViewModal").open();
    },
    closeMobileViewModal : function(cmp, event, helper){
        cmp.set("v.showMobileViewFilterModel",false);
    },
    mobileTabHandleChange : function(component, event, helper) {
        var tabName = event.currentTarget.name;
        var tabIcons = component.get("v.tabIcons");
        
        if(tabName == 'Search the Library'){
            if(tabIcons.showSearchTab){
                tabIcons.showSearchTab = false;
                tabIcons.searchtabIcon = 'utility:chevronright';
            }else{
                tabIcons.showSearchTab = true; 
                tabIcons.searchtabIcon = 'utility:chevrondown';
            }
        }else if(tabName == 'My Materials'){
            if(tabIcons.showMaterialTab){
                tabIcons.showMaterialTab = false;
                tabIcons.materialTabIcon = 'utility:chevronright';
                component.set("v.activityChecked",false);
            }else{
                tabIcons.showMaterialTab = true; 
                tabIcons.materialTabIcon = 'utility:chevrondown';
            }
        }
        component.set("v.tabIcons",tabIcons);
    },
    
   navigate : function(cmp, event, helper) {
      // this function call on click on the previous page button   
       var displayObj = cmp.get("v.displayObj");
       var filterObj = cmp.get("v.filterObj");
       var page = filterObj.pageNumber;

      // get the previous button label  
      var direction = event.getSource().get("v.label");
      // get the select option (drop-down) values.  
       var recordToDisply = filterObj.pageSize || 10;
      // set the current page,(using ternary operator.)  
      page = direction === "Previous" ? (page - 1) : (page + 1);
      // call the helper function
       
       filterObj.pageNumber = page;
       filterObj.pageSize = recordToDisply;
       cmp.set("v.filterObj",filterObj);
       cmp.set("v.showSpinner",true);
       helper.getSearchInputs(cmp, event); 
   },
    pagenationSelections : function(cmp, event, helper) {
        // Items Per Page Selection
        var filterObj = cmp.get("v.filterObj");
        filterObj.pageNumber = 1;
        cmp.set("v.filterObj",filterObj);

        cmp.set("v.showSpinner",true);
        helper.getSearchInputs(cmp, event); 
    }
})