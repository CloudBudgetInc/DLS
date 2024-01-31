({
    getFilters : function(cmp ,event ,helper) {
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getFilters');
        
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response is ---',response);
                var result = response;
                cmp.set("v.savedSearchList",result.savedFiltersList);
                cmp.set("v.contactTypeList",result.contactAssignmentTypeList);
                cmp.set("v.projectTypeList",result.projectTypeList);
                cmp.set("v.projectSectionList", result.projectSectionList);
                var isDefaultFound = false;
                
                var filter = cmp.get("v.filter");
                var selectedFilter = {};
                var isDefault = false;
                
                var projectRecordTypeList = [];
                var projectRTMap = {};
                
                for(var i = 0;i < result.projectTypeList.length; i++){
                    projectRecordTypeList.push(result.projectTypeList[i].label);
                    
                    projectRTMap[result.projectTypeList[i].value] = result.projectTypeList[i].label;
                }
                
                cmp.set("v.projectRecordTypeList",projectRecordTypeList);
                cmp.set("v.projectRTMap",projectRTMap);
                
                for(var i = 0; i < result.savedFiltersList.length; i++){
                    
                    if(response.defaultFilterId){
                        if(result.savedFiltersList[i].Id == response.defaultFilterId){
                            selectedFilter = result.savedFiltersList[i];
                            isDefault = true;
                            isDefaultFound = true;
                        }
                    }else if(result.savedFiltersList[i].Name == 'All'){
                        cmp.set("v.allFilterId",result.savedFiltersList[i].Id);
                        selectedFilter = result.savedFiltersList[i];
                        isDefaultFound = true;
                    }
                }
                
                if(isDefaultFound){
                    filter.selectedFilter = selectedFilter.Id;
                    filter.filterName = selectedFilter.Name;
                    filter.isDefault = isDefault;
                    
                    if(isDefault){
                        cmp.set("v.defaultId",selectedFilter.Id);
                    }
                    
                    cmp.set("v.filter",filter);
                    helper.applyFilterValues(cmp,event,helper,JSON.parse(selectedFilter.Filter_Value__c));
                }else{
                    helper.defaultFilters(cmp,event,helper,false);
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    defaultFilters : function(cmp ,event ,helper ,isClear) {
        var filterObj = cmp.get("v.filterObj");
        var multiPicklistFilter = cmp.get("v.multiPicklistFilter");
        var  filter = cmp.get("v.filter");
        
        filter.filterName = null;
        filter.isDefault = false;
        filter.Id = null;
        filter.selectedFilter = 'All'
        cmp.set("v.defaultId",null);
        cmp.set("v.filter",filter);
        
        filterObj['selectedStatusList'] = ['Active','Order'];
        filterObj['selectedAssignmentList'] = ['Active'];
        filterObj['SelectedPosition'] = 'All';
        filterObj['selectedContactAsssign'] = 'All';
        filterObj['selectedProjectRT'] = ['All'];
        filterObj['SelectedAccount'] = [];
        filterObj['SelectedLocation'] = [];
        filterObj['SelectedContact'] = [];
        filterObj['fieldToSort'] = 'name';
        filterObj['sortingOrder'] = 'Asc';
        filterObj['selectedSection'] = 'All';
        multiPicklistFilter['selectedStatusList'] = ['Active','Order'];
        multiPicklistFilter['selectedAssignmentList'] = ['Active'];
        multiPicklistFilter['selectedProjectRT'] = JSON.parse(JSON.stringify(cmp.get("v.projectRecordTypeList")));
        
        if(isClear){
            cmp.set("v.isLoaded",false);
        }else{
            cmp.set("v.isLoaded",true);
        }
        cmp.set("v.filterObj",filterObj);
        cmp.set("v.multiPicklistFilter",multiPicklistFilter);
        
        if(cmp.get("v.initialLoad")){
            cmp.find("multiSelect").reLoadPickList();
            cmp.find("projectstatus").reLoadPickList();
        }
        //this.getProjects(cmp,event,helper);
    },
    showToast :  function(cmp,event,message,type,title) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    applyFilterValues : function(cmp ,event ,helper ,filterCondition){
        var filterObj = cmp.get("v.filterObj");
        var multiPicklistFilter = cmp.get("v.multiPicklistFilter");
        
        //Account Name
        if(filterCondition['Account Name']){
              filterObj['SelectedAccount'] = filterCondition['Account Name'];
        }else{
            filterObj['SelectedAccount'] = [];
        }
        
        //Location
        if(filterCondition['Location']){
            var array = [];
            array.push(filterCondition['Location']);
            filterObj['SelectedLocation'] = array;
        }else{
            filterObj['SelectedLocation'] = [];
        }
        
        //Contact
        if(filterCondition['Contact']){
            var array = [];
            array.push(filterCondition['Contact']);
            filterObj['SelectedContact'] = array;
        }else{
            filterObj['SelectedContact'] = [];
        }
        
        //Contact Assignment Position
        if(filterCondition['Contact Assignment Position']){
            filterObj['SelectedPosition'] = filterCondition['Contact Assignment Position'];
        }else{
            filterObj['SelectedPosition'] = 'All';
        }
        
        //Contact Assignment Status
        if(filterCondition['Contact Assignment Status']){
            filterObj['selectedAssignmentList'] = filterCondition['Contact Assignment Status'];
            multiPicklistFilter['selectedAssignmentList'] = filterCondition['Contact Assignment Status'];
        }else{
            filterObj['selectedAssignmentList'] = [];
            multiPicklistFilter['selectedAssignmentList'] = [];
        }
        
        //Contact Assignment Record Type
        if(filterCondition['Contact Assignment Record Type']){
            filterObj['selectedContactAsssign'] = filterCondition['Contact Assignment Record Type'];
        }else{
            filterObj['selectedContactAsssign'] = 'All';
        }
        
        //Project Section
        if(filterCondition['Project Section']){
            filterObj['selectedSection'] = filterCondition['Project Section'];
        }else{
            filterObj['selectedSection'] = 'All';
        }
        
        //Project Status
        if(filterCondition['Project Status']){
            filterObj['selectedStatusList'] = filterCondition['Project Status'];
            multiPicklistFilter['selectedStatusList'] = filterCondition['Project Status'];
            
        }else if(filterCondition['Status']){
            filterObj['selectedStatusList'] = filterCondition['Status'];
            multiPicklistFilter['selectedStatusList'] = filterCondition['Status'];
        }else{
            filterObj['selectedStatusList'] = [];
            multiPicklistFilter['selectedStatusList'] = [];
        }   
        
        //Project Record Type
        if(filterCondition['Project Record Type']){
            if(typeof filterCondition['Project Record Type'] == 'string'){
                
                var projectRecordtype = '';
                var projectRTMap = cmp.get("v.projectRTMap");
                for(var key in projectRTMap){
                    if(key == filterCondition['Project Record Type']){
                        projectRecordtype = projectRTMap[key];
                    }
                }
                
                filterObj['selectedProjectRT'] = [];
            	filterObj['selectedProjectRT'].push(projectRecordtype);
                
                multiPicklistFilter['selectedProjectRT'] = [];
                multiPicklistFilter['selectedProjectRT'].push(projectRecordtype);
                
            }else if(typeof filterCondition['Project Record Type'] == 'object'){
                
                filterObj['selectedProjectRT'] = filterCondition['Project Record Type'];
                multiPicklistFilter['selectedProjectRT'] = filterCondition['Project Record Type'];
            }
            
        }else{
            filterObj['selectedProjectRT'] = JSON.parse(JSON.stringify(cmp.get("v.projectRecordTypeList")));
            multiPicklistFilter['selectedProjectRT'] = JSON.parse(JSON.stringify(cmp.get("v.projectRecordTypeList")));
        }
        
        cmp.set("v.multiPicklistFilter",multiPicklistFilter);
        cmp.set("v.filterObj",filterObj);
        helper.getPosition(cmp,event,helper);
        helper.getProjects(cmp,event,helper);
        
    },
    saveSearch : function(cmp ,event ,helper , filterRecord) {
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.SaveSearches');
        server.callServer(
            action,
            {ssList : JSON.stringify(filterRecord)},
            false,
            $A.getCallback(function(response) {
                var filterId = response;
                var oldDefaultId = cmp.get("v.defaultId");
                var isDefault = cmp.get("v.filter.isDefault");
                console.log(filterId,oldDefaultId,isDefault);
                if((isDefault && (oldDefaultId != filterId)) || (oldDefaultId == null&&isDefault) ){
                    console.log('should update this');
                    helper.updateContact(cmp,event,helper,filterId,'Update');
                }else if(!isDefault && (oldDefaultId == filterId)){
                    helper.updateContact(cmp,event,helper,filterId,'Remove');
                }else {
                    cmp.find('manageFilter').close();
                    helper.getFilters(cmp,event,helper);
                    setTimeout(function(){ 
                        cmp.set("v.showSpinner",false);
                    }, 500);
                }
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    
    updateContact : function(cmp ,event ,helper ,newDefaultId ,operation) {
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.updateContact');
        cmp.set("v.showSpinner",true);
        server.callServer(
            action,
            {newId : newDefaultId,
             operation : operation},
            false,
            $A.getCallback(function(response) {
                helper.getFilters(cmp,event,helper);
                cmp.find('manageFilter').close();
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );	
    },
    
    getProjects : function(cmp ,event ,helper){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getProjectList');
        var proSummaryInputs = {};
        var filterObj = cmp.get("v.filterObj");
        
        proSummaryInputs['projectStatus'] = filterObj.selectedStatusList;
        proSummaryInputs['cARTId'] = filterObj.selectedContactAsssign;
        proSummaryInputs['projectRTNames'] = filterObj.selectedProjectRT;
        proSummaryInputs['cAPosition'] = filterObj.SelectedPosition;
        proSummaryInputs['cAStatus'] = filterObj.selectedAssignmentList;
        proSummaryInputs['accountId'] = (filterObj.SelectedAccount).length > 0 ? filterObj.SelectedAccount : [];
        proSummaryInputs['locationId'] = (filterObj.SelectedLocation).length > 0 ? (filterObj.SelectedLocation)[0].Id : null;;
        proSummaryInputs['contactId'] = (filterObj.SelectedContact).length > 0 ? (filterObj.SelectedContact)[0].Id : null;
        proSummaryInputs['sortingFieldName'] = filterObj.fieldToSort;
        proSummaryInputs['sortingOrder'] = filterObj.sortingOrder;
        proSummaryInputs['selectedSection'] = filterObj.selectedSection;
        cmp.set("v.showSpinner",true);
        //console.log(JSON.stringify(proSummaryInputs));
        
        var param = {};
        param.proSummaryInputs = JSON.stringify(proSummaryInputs);
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var projectSummary = response;
                var counts =  cmp.get("v.counts");
                //console.log('final response is',response);
                cmp.set("v.ProjectSummaryList",projectSummary.projectSummaryList);
                counts.noOfProjects = projectSummary.noOfProjects;
                counts.remainingHours = projectSummary.remainingHours;
                counts.hoursWeek = projectSummary.hoursWeek;
                counts.activeInstructors = projectSummary.activeInstructors;
                counts.activeStudents = projectSummary.activeStudents;
                cmp.set("v.counts",counts);
                setTimeout(function(){ 
                    cmp.set("v.showSpinner",false);
                }, 500);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    
    getPosition : function(cmp ,event ,helper) {
        
        cmp.set("v.showSpinner",true);
        console.log('changed',cmp.get("v.filterObj.selectedContactAsssign"));
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getRecordTypeBased_PicklistValues');
        var recordTypeId = cmp.get("v.filterObj.selectedContactAsssign");
        
        server.callServer(
            action,
            {objectName : 'Contact_Assignments__c',
             fieldName : 'Assignment_Position__c',
             recordTypeId : recordTypeId},
            false,
            $A.getCallback(function(response) {
                //console.log('response',response);
                var positionPickList = JSON.parse(response);
                cmp.set("v.positionList",positionPickList);
                cmp.set("v.isLoaded",true);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    
    generateCsv : function(cmp ,event ,helper ,arrayOfData, tableHeader) {
        var csvContent = "data:text/csv;charset=utf-8,";
        
        for(var i = 0; i < tableHeader.length; i++) {
            csvContent += tableHeader[i].text;
            if(i != tableHeader.length - 1)
                csvContent += ',';
        }
        csvContent += '\n';
        for(var i = 0; i < arrayOfData.length; i++) {
            for(var j = 0; j < tableHeader.length; j++) {
                
              //  if(arrayOfData[i].hasOwnProperty(tableHeader[j].api)) {
                    var bodyContent = helper.getNodeValue(cmp, event, helper, tableHeader[j].api, arrayOfData[i]);
                    if(bodyContent == undefined) {
                        csvContent += '';
                    }else {
                        csvContent += bodyContent;
                    }
                    if(j != tableHeader.length - 1)
                        csvContent += ',';
              //  }
            }
            if(i != arrayOfData.length - 1)
                csvContent += '\n';
        }
        return csvContent;
    },
    
    getNodeValue : function(cmp, event, helper, header, columnContent) {
        console.log('Node value::::',header);
    	if(header && header.includes('.')) {
            var columnContent = columnContent;
    		var parentNodes = header.split('.');
            parentNodes.forEach(function(node) {
            	let content = columnContent[node];
    			columnContent = content;
                console.log('Project name ::', columnContent);
            });
            
    		return helper.validateContent(columnContent);
		}else {
    		return helper.validateContent(columnContent[header]);
		}
	},
    
    validateContent : function(columnContent) {
        if(columnContent && columnContent.includes(',')) {
            return '"'+columnContent+'"';
        }else {
            return columnContent;
        }
    },
    
    downloadCSV : function(cmp ,event ,helper ,csvContent, filename) {
        var encodedData = encodeURI(csvContent);
        var link = document.createElement("a");
        
        link.setAttribute('href', encodedData);
        link.setAttribute('download', filename + '.csv');
        link.click();
    },
    
    ProjectStatusUpdate :function(cmp,event,helper) {
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.updateProjectStatus');
        
        var projectRec = cmp.get("v.projectRec");
        
        var params = {};
        params.proId = projectRec.Id;
        params.dateValue = (projectRec.status == 'On Hold') ? projectRec.onHoldDt : projectRec.cancelledDt;
        params.reason = projectRec.cancellationReason;
        params.status = projectRec.status;
        
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                helper.getFilters(cmp,event,helper);
                setTimeout(function(){ 
                    cmp.set("v.showSpinner",false);
                }, 100);       
            }),
            $A.getCallback(function(errors) { 
                setTimeout(function(){ 
                    cmp.set("v.showSpinner",false);
                }, 1000); 
                helper.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    filterChangedHelper : function(cmp ,event ,helper) {
        cmp.set("v.showSpinner",true);
        if(cmp.get("v.isLoaded")){
            this.getProjects(cmp,event,helper);   
        }else{
            cmp.set("v.showSpinner",false);
        }
    }
})