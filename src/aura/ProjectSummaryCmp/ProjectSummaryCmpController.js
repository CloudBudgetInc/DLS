({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set("v.projectStatusList",['Active','Order','Staffing','On Hold','Ended','Canceled']);
        cmp.set("v.contactAssignmentStatus",['Active','Planned','On Hold','Ended']);
        helper.getFilters(cmp,event,helper);
    },
    filterSelect : function(cmp ,event ,helper) {
        
        var FilterId = cmp.get("v.filter.selectedFilter");
        var filterObject = cmp.get("v.filterObj");
        var filter = cmp.get("v.filter");
        
        cmp.set("v.showSpinner",true);
        
        let searchList = cmp.get("v.savedSearchList");
        var filterIndex = searchList.findIndex(x => x.Id === FilterId);
        console.log('filter index:::', filterIndex);
        if(filterIndex != -1 && searchList[filterIndex]) {
            console.log('filter name:::', searchList[filterIndex].Name);
            cmp.set("v.filter.selectedFilterName", searchList[filterIndex].Name);
        }
        
        cmp.set("v.ProjectSummaryList",[]);
        
        if(FilterId){
            if(FilterId != cmp.get("v.defaultId")){
                filter.isDefault = false;
            }
            var savedSearchList = cmp.get("v.savedSearchList");
            var selectedFilter;
            for(var i = 0; i < savedSearchList.length; i++){
                if(savedSearchList[i].Id == FilterId){
                    selectedFilter = savedSearchList[i];
                    filter.filterName = selectedFilter.Name;
                }
            }
            cmp.set("v.filter",filter);
            var filterCondition = JSON.parse(selectedFilter.Filter_Value__c);
            helper.applyFilterValues(cmp,event,helper,filterCondition);
        }else{
            helper.defaultFilters(cmp,event,helper);
        }
    },
    AccountlookupSearch : function(cmp ,event ,helper) {
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('Account').search(serverSearchAction);
    },
    LocationlookupSearch : function(cmp ,event ,helper) {
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('Location').search(serverSearchAction);
    },
    ContactlookupSearch : function(cmp ,event ,helper) {
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('Contact').search(serverSearchAction);
    },
    filterChanged : function(cmp ,event ,helper) {
        helper.filterChangedHelper(cmp,event,helper);        
    },
    tableSort : function(cmp ,event,helper) {
        var target = event.currentTarget;
        var name = target.getAttribute("data-name"); 
        var filterObj =  cmp.get("v.filterObj");
        
        filterObj.fieldToSort = name;
        var currentDir = cmp.get("v.arrowDirection");
        if (currentDir == 'arrowdown') {
            cmp.set("v.arrowDirection", 'arrowup');
            filterObj.sortingOrder = 'Asc';
        } else {
            cmp.set("v.arrowDirection", 'arrowdown');
            filterObj.sortingOrder = 'Desc';
        }
        cmp.set("v.filterObj",filterObj);
    },
    manageFilter : function(cmp ,event ,helper) {
        var filterObj = cmp.get("v.filterObj");
        var manageFilters = [];
        var recordTypeList = cmp.get("v.contactTypeList");
        var projectRTList = cmp.get("v.projectTypeList");
        var selectedFilterId = cmp.get("v.filter.selectedFilter");
        var savedSearchList = cmp.get("v.savedSearchList");
        
        cmp.set("v.isValidInput",true);
        for(var i = 0; i < savedSearchList.length; i++){
            if(savedSearchList[i].Id == selectedFilterId){
                cmp.set("v.filter.filterName",savedSearchList[i].Name);
            }
        }
        for(var key in filterObj){
            
            if(filterObj[key] && filterObj[key].length > 0){
                var obj = {};
                if(key == 'SelectedAccount' && filterObj[key]){
                    var names = '';
                    for(var i = 0;i < filterObj[key].length;i++){
                        names +=  filterObj[key][i].Name + ((filterObj[key].length-1 == i) ? '':',');
                    }
                    obj['label'] = 'Account Name';
                    obj['value'] = names;
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key == 'selectedStatusList'){
                    obj['label'] = 'Project Status';
                    obj['value'] = JSON.stringify(filterObj[key]);
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key =='SelectedLocation' && filterObj[key]){
                    obj['label'] = 'Location';
                    obj['value'] = filterObj[key][0].Name;
                    obj['Filtervalue'] = filterObj[key][0];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key =='SelectedContact' && filterObj[key]){
                    obj['label'] = 'Contact';
                    obj['value'] = filterObj[key][0].Name;
                    obj['Filtervalue'] = filterObj[key][0];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key == 'selectedContactAsssign'){
                    obj['label'] = 'Contact Assignment Record Type';
                    obj['value'] = filterObj[key];
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                    for(var i = 0; i < recordTypeList.length; i++){
                        if(recordTypeList[i].value == filterObj[key]){
                            obj['value'] = recordTypeList[i].label;
                        }
                    }
                }else if(key == 'selectedProjectRT'){
                    obj['label'] = 'Project Record Type';
                    obj['value'] = JSON.stringify(filterObj[key]);
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key == 'SelectedPosition'){
                    obj['label'] = 'Contact Assignment Position';
                    obj['value'] = filterObj[key];
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;
                }else if(key == 'selectedAssignmentList'){
                    obj['label'] = 'Contact Assignment Status';
                    obj['value'] = JSON.stringify(filterObj[key]);
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;                
                }else if(key == 'selectedSection'){
                    obj['label'] = 'Project Section';
                    obj['value'] = JSON.stringify(filterObj[key]);
                    obj['Filtervalue'] = filterObj[key];
                    obj['condition'] = 'Equals';
                    obj['isSelected'] = true;                
                }
            }
            
            if((filterObj[key] && filterObj[key].length > 0)){
                if((key != 'fieldToSort' && key != 'sortingOrder')){
                    manageFilters.push(obj);
                }
            }
        }
        
        cmp.set("v.manageFilter",manageFilters);
        cmp.find('manageFilter').open();
    },
    closeModal :function(cmp ,event ,helper) {
        cmp.find('manageFilter').close();
        cmp.set("v.isValidInput",false);
    },
    saveAsFilter : function(cmp ,event ,helper) {
        var filterName = cmp.get("v.filter.filterName");
        var filterObject = cmp.get("v.filterObj");
        var savedSearchList = cmp.get("v.savedSearchList");
        var manageFilters = cmp.get("v.manageFilter");
        var newSavedSearch = [];
        var isValid = true;
        var filterNameCmp = cmp.find("filterName");
        var tempObj = {};
        
        for(var i = 0; i < savedSearchList.length; i++){
            if(savedSearchList[i].Name == filterName){
                isValid = false;
            }
        }
        if((!filterName) || !isValid) {
            cmp.set("v.filter.filterName",null);
            filterNameCmp.showHelpMessageIfInvalid(); 
        }else {
            for(var i = 0; i < manageFilters.length; i++){
                console.log('manageFilters',manageFilters[i]);
                if(manageFilters[i] && manageFilters[i].isSelected){
                    tempObj[manageFilters[i].label] = manageFilters[i].Filtervalue;
                }
            }
            newSavedSearch.push({'Filter_Value__c':JSON.stringify(tempObj),'Name':cmp.get("v.filter.filterName"),'Id':null});
            helper.saveSearch(cmp,event,helper,newSavedSearch);
        }
    },
    saveFilter : function(cmp ,event ,helper) {
        var isValidated = false;
        var filterObj = cmp.get("v.filterObj");
        var manageFilters = cmp.get("v.manageFilter");
        var newSavedSearch = [];
        var tempObj = {};
        
        for(var i =0; i < manageFilters.length; i++){
            console.log('manageFilters',manageFilters[i]);
            if(manageFilters[i] && manageFilters[i].isSelected){
                tempObj[manageFilters[i].label] = manageFilters[i].Filtervalue;
            }
        }
        var id = cmp.get("v.filter.selectedFilter");
        var name = cmp.get("v.filter.filterName");
        console.log(id, name);
        if(!id && id != 'All'){
            id = null;
        }
        if(!name){
            var inputCmp = cmp.find("filterName");
            var value = inputCmp.get("v.value");
            inputCmp.showHelpMessageIfInvalid(); 
        }else{
            newSavedSearch.push({'Filter_Value__c':JSON.stringify(tempObj),'Name':cmp.get("v.filter.filterName"),'Id':id});
            helper.saveSearch(cmp,event,helper,newSavedSearch);
        }
    },
    clearFilter : function(cmp ,event ,helper) {
        //  cmp.set("v.isLoaded",false);
        cmp.set("v.showSpinner",true);
        helper.defaultFilters(cmp,event,helper,true);
        helper.getProjects(cmp,event,helper);
        setTimeout(function(){ 
            cmp.set("v.showSpinner",false);
        }, 3000); 
    },
    deleteRec : function(cmp ,event ,helper){
        cmp.set("v.isValidInput",false);
        cmp.set("v.showSpinner",true);
        var id = cmp.get("v.filter.selectedFilter");
        if(id == ''){
            cmp.find('manageFilter').close();
        }else{
            const server = cmp.find('server');
            const action = cmp.get('c.deleteFilter');
            server.callServer(
                action,
                {ssId : id},
                false,
                $A.getCallback(function(response) {
                    var filter = cmp.get("v.filter");
                    filter.filterName = null;
                    filter.isDefault = false;
                    filter.Id = null;
                    filter.defaultId = null;
                    filter.selectedFilter = null;
                    cmp.set("v.filter",filter);
                    helper.getFilters(cmp,event,helper);
                    cmp.find('manageFilter').close();
                    
                }),
                $A.getCallback(function(errors) { 
                    setTimeout(function(){ 
                        cmp.set("v.showSpinner",false);
                    }, 3000); 
                    helper.showToast(cmp,event,errors[0].message,'error','Error');
                }),
                false, 
                false,
                false
            );
        }
    },
    downloadFile :function(cmp ,event ,helper) {
        cmp.set("v.showSpinner",true);
        var type = event.currentTarget.getAttribute("data-name");
        var projectIdList=[];
        var projectList = cmp.get("v.ProjectSummaryList");
        
        for(var i = 0; i < projectList.length; i++){
            console.log(projectList[i].projectId);
            projectIdList.push(projectList[i].projectId.Id);
        }
        console.log(projectIdList);
        const server = cmp.find('server');
        const action = cmp.get('c.downloadCsvFile');
        server.callServer(
            action,
            {projectIdList : projectIdList,
             type :type},
            false,
            $A.getCallback(function(response) {
                console.log('response',response)
                var filename = '';
                var arrayOfData = response;
                var tableHeader = [];
                var datenow = Date(Date.now(), "DD-MMM-YYYY");
                datenow = datenow.substring(0, 15);
                
                if(type == 'Instructor') {
                    tableHeader = [{
                                       api:'firstname',
                                       text:'First Name'
                                   },
                                   {
                                       api:'lastName',
                                       text:'Last Name'
                                   },
                                   {
                                       api:'email',
                                       text:'Email'
                                   },
                                   {
                                       api:'recordType',
                                       text:'Contact Type'
                                   },
                                   {
                                       api:'language',
                                       text:'Language'
                                   }];
                    filename = 'Active Instructor info -'+datenow;
                }else {
                    tableHeader = [{
                     				  api:'firstname',
                       				  text:'First Name'
                  				   },
                                   {
                                       api:'lastName',
                                       text:'Last Name'
                                   },
                                   {
                                       api:'email',
                                       text:'Email'
                                   },
                                   {
                                       api:'recordType',
                                       text:'Contact Type'
                                   },
                                   {
                                       api:'accName',
                                       text:'Account Name'
                                   },
                                   {
                                       api:'language',
                                       text:'Language'
                                   }];
                    filename = 'Active Student info -'+datenow;
                }
                var scvFile = helper.generateCsv(cmp,event,helper,arrayOfData,tableHeader);
                helper.downloadCSV(cmp,event,helper,scvFile,filename);
                setTimeout(function(){ 
                    cmp.set("v.showSpinner",false);
                }, 1000); 
            }),
            $A.getCallback(function(errors){ 
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
    changeStatus : function(cmp ,event ,helper) {
        var target = event.currentTarget;
        var projectId = target.getAttribute("data-id");
        var status = target.getAttribute("data-status");
        var name = target.getAttribute("data-name");
        
        var projectRec = {};
        projectRec.Id = projectId;
        projectRec.status = '';
        projectRec.Name = name;
        
        cmp.set("v.projectRec",projectRec);
        var newStatusList = cmp.get("v.newStatusList");
        var updatedStausList = [];
        for(var i = 0; i < newStatusList.length; i++){
            if(status != newStatusList[i]){
                updatedStausList.push(newStatusList[i]);
            }
        }
        cmp.set("v.tempStatusList",updatedStausList);
        cmp.find('statusUpdate').open();
    },
    updateStatus : function(cmp ,event ,helper) {
        var projectRec = cmp.get("v.projectRec");
        var status = projectRec.status;
        var projectId = projectRec.Id;
        
        var isValid = true;
        
        if(status){
            
            if(status == 'On Hold'){
                
                var dtCmp = cmp.find("dtVal");
                if(!dtCmp.get("v.value")){
                    dtCmp.set("v.errors", [{message:" "}]);
                    isValid = false;
                }else {
                    dtCmp.set("v.errors", null);
                }
            }else if(status == 'Canceled'){
                
                var dtCmp = cmp.find("cancelDt");
                if(!dtCmp.get("v.value")){
                    dtCmp.set("v.errors", [{message:" "}]);
                    isValid = false;
                }else {
                    dtCmp.set("v.errors", null);
                }
                
                var reasoncmp = cmp.find("cancelReason");
                if(!reasoncmp.get("v.value")){
                    $A.util.addClass(reasoncmp,"slds-has-error");
                    isValid = false;
                }else {
                    $A.util.removeClass(reasoncmp,"slds-has-error");
                }
                
            }
            
            if(isValid){
                cmp.find('statusUpdate').close();
                cmp.set("v.showSpinner",true);
                
                if(status == 'Ended'){
                    var url = '/apex/Manage_Project_Dates?Id='+projectId+'&SetProjectStatus=Ended&return=ToProjectSummary';
                    window.open(url,'_self');
                }else {
                    helper.ProjectStatusUpdate(cmp,event,helper);    
                }
            }
            
        }else{
            cmp.set("v.showSpinner",false);
            $A.util.addClass(statusCmp, 'slds-has-error');    
        }
    },
    closeStatus :function(cmp ,event ,helper) {
        cmp.find('statusUpdate').close();
        var statusCmp = cmp.find("newStatus");
        $A.util.removeClass(statusCmp, 'slds-has-error'); 
    },
    openCurrency : function(cmp ,event ,helper) {
        var recId = event.getSource().get("v.name");
        var actions = cmp.get("v.actions");
        
        cmp.set("v.showSpinner",true);
        cmp.find("actionCmps").open();
        actions.budjet = true;
        actions.schedule = false;
        actions.conAssign = false;
        actions.Id = recId;
        cmp.set("v.actions",actions);
        
        setTimeout(function(){ 
            cmp.set("v.showSpinner",false);
        }, 1000); 
    },
    openConAssignment : function(cmp ,event ,helper) {
        var recId = event.getSource().get("v.name");
        var actions = cmp.get("v.actions");
        
        cmp.set("v.showSpinner",true);
        cmp.find("actionCmps").open();
        actions.budjet = false;
        actions.schedule = false;
        actions.conAssign = true;
        actions.Id = recId;
        cmp.set("v.actions",actions);
        
        setTimeout(function(){ 
            cmp.set("v.showSpinner",false);
        }, 1000); 
    },
    openSchedules : function(cmp ,event ,helper) {
        var recId = event.getSource().get("v.name");
        var actions = cmp.get("v.actions");
        //console.log('recId:>:::'+recId);
        cmp.set("v.showSpinner",true);
        cmp.find("actionCmps").open();
        actions.budjet = false;
        actions.schedule = true;
        actions.conAssign = false;
        actions.Id = recId;
        cmp.set("v.actions",actions);
        
        setTimeout(function(){ 
            cmp.set("v.showSpinner",false);
        }, 3000); 
    },
    closeActions : function(cmp ,event ,helper) {
        cmp.find("actionCmps").close();
        
        //Added By Dhinesh - 11/10/2021 - W-007084 - Fix the project id not updated when the schedule is opened for different projects
        cmp.set("v.actions", {'budjet':false,'schedule':false,'conAssign':false,'Id':null});
    },
    filterMultiPicklistChange : function(cmp ,event ,helper) {
        var multiPicklistFilter = cmp.get("v.multiPicklistFilter");
        var filterObj = cmp.get("v.filterObj");
        
        
        if(filterObj['selectedStatusList'] != multiPicklistFilter['selectedStatusList'] 
           ||  filterObj['selectedAssignmentList'] != multiPicklistFilter['selectedAssignmentList']
          || filterObj['selectedProjectRT'] != multiPicklistFilter['selectedProjectRT']){
            
            filterObj['selectedStatusList'] = multiPicklistFilter['selectedStatusList'];
            filterObj['selectedAssignmentList'] = multiPicklistFilter['selectedAssignmentList'];
            filterObj['selectedProjectRT'] = multiPicklistFilter['selectedProjectRT'];
            
            cmp.set("v.filterObj",filterObj);
        }
    },
    printView : function(cmp ,event ,helper) {
        cmp.set("v.isPagePrintVersion",true);
        setTimeout(function(){ 
            window.print();
        }, 10);
        
        setTimeout(function(){ 
            cmp.set("v.isPagePrintVersion",false);
        },10);
    },
    getCAPosition : function(cmp ,event ,helper) {
        var selectedContactAsssign = cmp.get("v.filterObj").selectedContactAsssign;
        helper.getPosition(cmp ,event ,helper);
    },
    
    /*--For Export Functionality---*/
    exportView : function(cmp, event, helper) {
        if(cmp.get("v.filter.selectedFilter") == cmp.get("v.allFilterId") || !cmp.get("v.filter.selectedFilter")) {
            helper.showToast(cmp,event,'Export is not available for ALL view','warning','Warning');
        }else {
            console.log('ProjectSummaryList:::', cmp.get("v.ProjectSummaryList"));
            var arrayOfData = cmp.get("v.ProjectSummaryList");
            if(arrayOfData.length > 0) {
                var tableHeader = [{api:'projectId.Name',text:'Name'},{api:'dlsRef',text:'DLS Ref'},
                                   {api:'stDate',text:'Start Date'},{api:'endDate',text:'End Date'},
                                   {api:'scheduledHour',text:'Scheduled Hours/Week'},{api:'accountName',text:'Account Name'},
                                   {api:'languageName',text:'Language'},{api:'rooms',text:'Room(s)'},
                                   {api:'remainingHrs',text:'Hours Remaining'},{api:'projectStatus',text:'Project Status'},
                                   {api:'activeInstructors',text:'Active Instructor(s)'},{api:'activeStudents',text:'Active Student(s)'}
                                  ];
                
                var filename = 'Project Summary - '+cmp.get("v.filter.selectedFilterName");
                var csvFile = helper.generateCsv(cmp,event,helper,arrayOfData,tableHeader);
                helper.downloadCSV(cmp,event,helper,csvFile,filename);
                setTimeout(function(){ 
                    cmp.set("v.showSpinner",false);
                }, 1000);     
            }else {
                helper.showToast(cmp,event,'No records found','error','Error');
            }
        }
        
    },
    openActivities : function(cmp ,event ,helper) {
        var recId = event.getParam('whatId');
        var actions = cmp.get("v.actions");
        actions.Id = recId;
        cmp.set('v.actions',actions);
        cmp.set('v.isActivitiesOpened',true);
        cmp.find("activitiesModal").open();
    },
    closeActivities : function(cmp ,event ,helper) {
        cmp.set('v.isActivitiesOpened',false);
        cmp.find("activitiesModal").close();
        cmp.set("v.actions", {'budjet':false,'schedule':false,'conAssign':false,'Id':null});
    }
    
})