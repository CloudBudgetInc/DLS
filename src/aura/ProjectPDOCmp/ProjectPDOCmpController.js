({
	doInit : function(component, event, helper) {
		var header=[            
            {
                'label':'Contact',
                'name':'contactName', 
                'type':'string',
                'sortable':true              
            }, 
            {
                'label':'Date',
                'name':'Date', 
                'type':'text',
                'sortable':true
                
            },
            {
                'label':'Description',
                'name':'Description__c',
                'type':'text',
                'sortable':false
                
            },
            {
                'label':'Type',
                'name':'Type__c',
                'type':'text',
                'sortable':false
                
            },            
            {
                'label':'Status',
                'name':'Status__c',
                'truncate' : {
                    "characterLength" :15
                },
                'sortable':false
            }];
        
        var tableConfig = {
            
            "paginate":true,
            "searchByColumn":false,
            "searchBox":false,
            "sortable":true,
            "rowAction": [],
        }
        component.set("v.tableConfig",tableConfig);
        component.set("v.tableColumns",header);
        console.log('planneddaysoff');
        helper.getPlannedDaysOffRows(component, event, helper);        
	}
})