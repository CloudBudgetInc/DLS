({
	doinit : function(cmp, event, helper) {
        console.log('::::::material::Id::::::',cmp.get("v.recordId"));
        console.log(':::::userType::::::',cmp.get("v.userType"));
        helper.materialRelatedInformation(cmp, event);
	},
    addReviewBtnClick : function(cmp, event, helper){
        cmp.set("v.displayRatingInfo",false);
        cmp.set("v.displayNewRatingSection",true);
    },
    saveNewRating : function(cmp, event, helper){
        console.log(':::::::rating::obj:::',JSON.stringify(cmp.get("v.ratingObj")));
        cmp.set("v.showSpinner",true);
        helper.ratingCreation(cmp, event);
    },
    cancelNewRating : function(cmp, event, helper){
        cmp.set("v.displayNewRatingSection",false);  
        cmp.set("v.displayRatingInfo",true);
        cmp.set("v.ratingObj",{});
    },
    updateReviewBtnClick : function(cmp, event, helper){
        cmp.set("v.displayRatingInfo",false);
        cmp.set("v.displayUpdateRatingSection",true);
        cmp.set("v.ratingObj",cmp.get("v.MaterialDetials").currentUserRating[0]);
    },
    updateRating : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.updateReview(cmp, event);
    },
    cancelUpdateRating : function(cmp, event, helper){
        cmp.set("v.displayRatingInfo",true);
        cmp.set("v.displayUpdateRatingSection",false);
        cmp.set("v.ratingObj",{});
    },
    saveLTSDescription : function(cmp, event, helper){
        helper.updateLTSDescription(cmp, event);
    },
    markAsFavourite : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var obj = {};
        obj.Contact__c = cmp.get("v.MaterialDetials").contactId;
        obj.Material_Name__c = cmp.get("v.recordId");
        
        var createArray = [];
        createArray.push(obj);
        
        var param = {};
        param.createJson = JSON.stringify(createArray);
        param.objectName = 'Favourite_Material__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.createForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log(':::Favourite::::record::;created:',response);
                helper.materialRelatedInformation(cmp,event);
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
    removeFavourite : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var param = {};
        param.deleteJson = JSON.stringify(cmp.get("v.MaterialDetials").favouriteList);
        param.objectName = 'Favourite_Material__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.deleteForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log(':::favourite::removal::::',response);
                helper.materialRelatedInformation(cmp,event);
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
    newOrderBtnClick : function(cmp, event, helper){
        cmp.set("v.isNewRequest",true);
    },
    newLoanBtnClick : function(cmp, event, helper){
         cmp.set("v.isNewLoan",true);
    },
    isNewRequestChanged : function(cmp, event, helper){
        if(!cmp.get("v.isNewRequest")){
            cmp.set("v.showSpinner",true);
            helper.materialRelatedInformation(cmp,event);
        }
    },
    isNewLoanChanged : function(cmp, event, helper){
        if(!cmp.get("v.isNewLoan")){
            cmp.set("v.showSpinner",true);
            helper.materialRelatedInformation(cmp,event);
        }
    },
    openEditRecord : function(cmp, event, helper){
        
		var data = event.target.getAttribute("data-name");
        var index = parseInt(data.split('-')[0]);
        var type = data.split('-')[1];
        console.log("index::::::::",index);
        console.log("::::::type::::::",type);
        
        if(type == 'Order'){
            cmp.set("v.materialRequestRecord",cmp.get("v.MaterialDetials").orderMaterialRequests[index]);
        }else if(type == 'Loan'){
            cmp.set("v.materialRequestRecord",cmp.get("v.MaterialDetials").loanMaterialRequests[index]);
        }
		        
        cmp.set("v.displayEdit",true);
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].open();
        }else {
            cmp.find("editModal").open();
        }
    },
    saveEditedRecord : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.find("edit").get("e.recordSave").fire();
    },
    closeEdit : function(cmp, event, helper){
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].close();
        }else {
            cmp.find("editModal").close();
        }
        cmp.set("v.displayEdit",false);
    },
    handleSaveSuccess : function(cmp, event, helper){
        console.log('success');
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].close();
        }else {
            cmp.find("editModal").close();
        }
        cmp.set("v.displayEdit",false);
        helper.materialRelatedInformation(cmp,event);
    },
    backToHomePage : function(cmp, event, helper){
        if(!cmp.get("v.fromType")){
            cmp.set("v.displaySearchResult",true);
        }else if(cmp.get("v.fromType") == 'Favorite'){
            cmp.set("v.displayfavoriteSection",true);
        }else if(cmp.get("v.fromType") == 'Top Rated'){
            cmp.set("v.displayTopRatedSection",true);
        }
        
    },
    updateRatingByInternal : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var index = event.target.getAttribute("data-index");
        var type = event.target.getAttribute("data-type");
        
        console.log(':::index:::type::::::',index,type);
        
        var overAllRating = cmp.get("v.MaterialDetials").overAllRatings;
        
        var obj = {};
        obj.Id = overAllRating[index].Id;
        obj.Hide_to_Community__c = type == 'include'? true : false;
        
        var rating = [];
        rating.push(obj);
        
        var param = {};
        param.updateJson = JSON.stringify(rating);
        param.objectName = 'Material_Rating__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.updateForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log('rating::update:',response);
                helper.materialRelatedInformation(cmp,event);
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
    tabClick : function(cmp, event, helper){
        var tabName = event.currentTarget.name;
        cmp.set("v.tabName",tabName);
    }
})