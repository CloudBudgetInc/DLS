({
	getContentVersionDetails : function(cmp, event) {
		var self = this;
        var param = {};
        param.userType = cmp.get("v.userType");
        param.contentVersionId = cmp.get("v.recordId");
        
        const server = cmp.find('server');
        const action = cmp.get('c.getContentVersionAllDetails');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result::content::detail:::',result);
                
                if(result.favouriteList.length > 0){
                    cmp.set("v.showFavouriteIcon",true);
                    cmp.set("v.showUnFavouriteIcon",false);
                }else {
                    cmp.set("v.showFavouriteIcon",false);
                    cmp.set("v.showUnFavouriteIcon",true);
                }
                
                if(result.contentRec.LTS_Description__c){
                    cmp.set("v.disableDescriptionEdit",true);
                }else if(result.allowLTS_EditDescription){
                    cmp.set("v.disableDescriptionEdit",false);
                }else {
                    cmp.set("v.disableDescriptionEdit",true);
                }     
                
                if(result.currentUserRating.length > 0){
                    result.overAllRatingDetails.push(result.currentUserRating[0]);
                }
                
                cmp.set("v.contentDetails",result);
                var size = self.byteToSize(cmp,result.contentRec.ContentSize);
                cmp.set("v.contentSize",size);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	},
    showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    byteToSize : function(cmp, bytes){
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) {
           return '0 Byte'; 
        }
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    },
    ratingCreation : function(cmp, event){
        var rating = [];
        var curr = new Date();
        var date = curr.getDate();
        var month = curr.getMonth()+ 1;
        var year = curr.getFullYear();
        
        if(month < 10)
            month = '0'+month;
        if(date < 10)
            date = '0'+date;
        
        var currentDate = year+'-'+month+'-'+date;
        var ratingObj = cmp.get("v.ratingObj");
        var rate = ratingObj.Ratings__c.toString();
        rating.push({Rating__c:rate,Review__c:ratingObj.Review__c,ContentVersionId__c:cmp.get("v.recordId"),Date__c:currentDate,Contact__c:cmp.get("v.contentDetails").currentContactId,Hide_to_Community__c : ratingObj.Hide_to_Community__c});
        console.log(':::::::raitng::::',rating);
        
        var self = this;
        var param = {};
        param.createJson = JSON.stringify(rating);
        param.objectName = 'Material_Rating__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.createForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log('rating::creation:',response);
                self.getContentVersionDetails(cmp,event);
                cmp.set("v.displayNewRatingSection",false);  
                cmp.set("v.displayRatingInfo",true);
                cmp.set("v.ratingObj",{});
                //cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    updateReview : function(cmp, event){
        var rating = [];
        
        var ratingObj = cmp.get("v.ratingObj");
        var rate = ratingObj.Ratings__c.toString();
        rating.push({Id :ratingObj.Id, Rating__c:rate,Review__c:ratingObj.Review__c,Hide_to_Community__c : ratingObj.Hide_to_Community__c});
        console.log(':::::::raitng::::',rating);
        
        var self = this;
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
                self.getContentVersionDetails(cmp,event);
                cmp.set("v.displayRatingInfo",true);
                cmp.set("v.displayUpdateRatingSection",false);
                cmp.set("v.ratingObj",{});
                //cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    updateLTSDescription : function(cmp, event){
        
        var contentRecord = [];
        var rec = cmp.get("v.contentDetails").contentRec;
        contentRecord.push({Id : cmp.get("v.recordId"),LTS_Description__c : rec.LTS_Description__c});
        
        var self = this;
        var param = {};
        param.updateJson = JSON.stringify(contentRecord);
        param.objectName = 'ContentVersion';
        
        const server = cmp.find('server');
        const action = cmp.get('c.updateForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log('::update::::::LTS:;description:',response);
                self.getContentVersionDetails(cmp,event);
                //cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    }
})