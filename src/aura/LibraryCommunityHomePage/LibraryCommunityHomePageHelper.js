({
	getSummaryValues : function(cmp, event) {
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityHomePageDetails');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('Comm:home:::page::::',result);
                cmp.set("v.displayMap",result);
                cmp.set("v.showSpinner",false);
                self.filterRequestRecords(cmp);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors);
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	},
    orderTableHeaderFormation : function(cmp){
        
        var userType = cmp.get("v.userType");
        
        var header = [
            {
                'label':'Request #',
                'name':'Name',
                'type':'string',
                'sortable':false
            },
            /*{
                'label':'DLS Class #',
                'name':'Project__r.DLS_Class__c', 
                'type':'Strung',
                'sortable':false
            },*/
            {
                'label':'Material Title',
                'name':'Materials_Name__r.Name', 
                'type':'String',
                'sortable':true
            },
            {
                'label':'Requested Date',
                'name':'CreatedDate', 
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            }, 
            {
                'label':(cmp.get("v.userType") == 'Instructor' ? 'Due Date' : 'Est Arrival Date'),
                'name':(cmp.get("v.userType") == 'Instructor' ? 'Due_Date__c' : 'Est_Arrival_Date__c'),
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Ordered Date',
                'name':'Date_Ordered__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false,
            },
            {
                'label':'Delivered Date',
                'name':'Date_Delivered__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Status',
                'name':'Request_Status__c',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Project End Date',
                'name':'Project__r.End_Date__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Delivery Location',
                'name':'Delivery_Location__c',
                'type':'String',
                'sortable':false
            }
        ];
        cmp.set("v.orderHeaders",header);
    },
    loanTableHeaderFormation : function(cmp){
        var header = [
            {
                'label':'DLS Class #',
                'name':'Project__r.DLS_Class__c', 
                'type':'Strung',
                'sortable':false,
                'truncate' : {}
            },
            {
                'label':'Material Title',
                'name':'Materials_Name__r.Name', 
                'type':'String',
                'sortable':false
            }, 
            {
                'label':'Date Loaned Out',
                'name':'Date_Loaned_Out__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Date Returned',
                'name':'Date_Returned__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Status',
                'name':'Request_Status__c',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Project End Date',
                'name':'Project__r.End_Date__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Library Location',
                'name':'Location__r.Name',
                'type':'String',
                'sortable':false
            }
        ];
        cmp.set("v.loanHeaders",header);
    },
    filterRequestRecords : function(cmp){
        var tabName = cmp.get("v.tabName");
        if(cmp.get("v.userType") == 'Instructor'){
            var loanRecords = [];
            var wholeLoans = cmp.get("v.displayMap").loanRequests;
            for(var i = 0;i < wholeLoans.length;i++){
                if(wholeLoans[i].Request_Status__c == cmp.get("v.selectedStatus")){
                    loanRecords.push(wholeLoans[i]);
                    console.log(wholeLoans[i].Request_Status__c);
                }
            }
            cmp.set("v.loanRecords",loanRecords);
            
            cmp.find("loanTable").initialize({
                "itemMenu":[3,6,10,20,30],
                "itemsPerPage" : 3
            });
        }else {
           if(tabName == 'Loan'){
                var loanRecords = [];
                var wholeLoans = cmp.get("v.displayMap").loanRequests;
                for(var i = 0;i < wholeLoans.length;i++){
                    if(wholeLoans[i].Request_Status__c == cmp.get("v.selectedStatus")){
                        loanRecords.push(wholeLoans[i]);
                    }
                }
                cmp.set("v.loanRecords",loanRecords);
               
               cmp.find("loanTable").initialize({
                    "itemMenu":[3,6,10,20,30],
                    "itemsPerPage" : 3
                });
           }else {
               cmp.set("v.orderRecords",cmp.get("v.displayMap").orderRequests);
               cmp.find("orderTable").initialize({
                   "itemMenu":[3,6,10,20,30],
                   "itemsPerPage" : 3
               });
           }
        }
    }
})