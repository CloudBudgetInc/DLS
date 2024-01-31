({
	doinit : function(cmp, event, helper) {
        console.log(':::content::Id:::::',cmp.get("v.recordId"));
        cmp.set("v.showSpinner",true);
        helper.getContentVersionDetails(cmp, event);
	},
    saveLTSDescription : function(cmp, event, helper){
        helper.updateLTSDescription(cmp, event);
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
        cmp.set("v.ratingObj",cmp.get("v.contentDetails").currentUserRating[0]);
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
    downloadContent : function(cmp, event, helper){
        var prefix = $A.get("$Label.c.Org_Prefix_Start_URL");
        window.location.href = prefix+'/sfc/servlet.shepherd/version/download/'+cmp.get("v.recordId")+'?';
    },
    markAsFavourite : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var obj = {};
        obj.Contact__c = cmp.get("v.contentDetails").currentContactId;
        obj.ContentVersion_Id__c = cmp.get("v.recordId");
        
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
                helper.getContentVersionDetails(cmp,event);
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
        param.deleteJson = JSON.stringify(cmp.get("v.contentDetails").favouriteList);
        param.objectName = 'Favourite_Material__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.deleteForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log(':::favourite::removal::::',response);
                helper.getContentVersionDetails(cmp,event);
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
    backToHomePage : function(cmp, event, helper){
        cmp.set("v.displaySearchResult",true);
    },
    updateRatingByInternal : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var index = event.target.getAttribute("data-index");
        var type = event.target.getAttribute("data-type");
        
        console.log(':::index:::type::::::',index,type);
        
        var overAllRating = cmp.get("v.contentDetails").overAllRatingDetails;
        
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
    }
})