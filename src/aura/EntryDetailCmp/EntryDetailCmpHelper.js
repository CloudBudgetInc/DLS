({
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getSpecificDateInformation : function(component){
        component.set("v.showSpinner",true);
        console.log("enter getSpecificDateInformation");
        var entriesDetails = component.get("v.specificWeekInfo").entryDetails;
        var selectedDate = this.apexDateFormatFunction(component.get("v.dateSelected"));
        var selectedDateIndex = component.get("v.selectedDateIndex");
        var entriesArr = [];
        var UniqueKeySet = [];
        
        var selectedEntriesList = entriesDetails[selectedDateIndex];
        for(var i = 0;i < entriesDetails.length;i++){
            if(entriesDetails[i].hasOwnProperty("entries")) {
                var records = [];
                records = entriesDetails[i].entries;
                if(records){
                    for(var j = 0;j < records.length;j++){
                        if(records[j].dateVal == selectedDate) {
                            entriesArr.push(records[j]);
                            var key = records[j].projectId+'-'+records[j].taskId+'-'+records[j].isBillable+'-'+records[j].payrollItem+'-'+records[j].locationId;
                            if(UniqueKeySet.indexOf(key) === -1){
                                UniqueKeySet.push(key);
                            }
                        }
                    }
                }
            }
        }
        console.log("entriesArr:::::::::::::::",entriesArr);
        component.set("v.timeDayList",entriesArr);
        component.set("v.UniqueKeySet",UniqueKeySet);
        component.set("v.showSpinner",false);
    },
    dayRecordsSaveFunction: function(component){
        component.set("v.showSpinner",true);
        var dayList = component.get("v.timeDayList");
        console.log("dayList:::::::::::1::::::",dayList);
        var changesMade = false;
        for(var i = 0;i < dayList.length;i++){
            if((dayList[i].isNew && dayList[i].hours != null) 
               || (dayList[i].isUpdated && dayList[i].hours != null )) {
                //console.log("enter if:::::::::::::");
                if(dayList[i].isNew){
                    //console.log("enter 2:::::::if:::::::::::::");
                    dayList[i].status = 'Draft';
                }
                changesMade = true;
            }
        }
        
        //console.log(':::::::::on:::save::',component.get("v.specificWeekInfo").entryDetails);
        //To save the Fringe-Holiday hrs on first time entry on that week
        //Added by NS on Nov 22 2018
        var specificWeekData = component.get("v.specificWeekInfo").entryDetails;
        var entriesArr = [];
        for(var i = 0;i < specificWeekData.length;i++){
            if(specificWeekData[i].hasOwnProperty("entries") && specificWeekData[i].dateVal != component.get("v.dateSelected")) {
                var records = [];
                records = specificWeekData[i].entries;
                if(records){
                    for(var j = 0;j < records.length;j++){
                        if(records[j].dayId == null && records[j].hours != null 
                           && records[j].isNew && records[j].isHoliday) {
                            entriesArr.push(records[j]);
                        }
                    }
                }
            }
        }
        //console.log('::::::::::entriesArr:::::',entriesArr);
        
        if(entriesArr.length > 0){
            dayList = dayList.concat(entriesArr);
        }
        
        console.log("changesMade:::::::",changesMade);
        if(changesMade) {
            var action = component.get("c.dmlOperationFunction");
            //console.log('::::dayList::before::::servercall::',dayList);
            action.setParams({
                timeDayJson: JSON.stringify(dayList),
                conId: component.get("v.initialValues").contactId,
                startDate: component.get("v.specificWeekInfo").startDate,
                endDate: component.get("v.specificWeekInfo").endDate
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log(":::::::::::get::::::::",response.getReturnValue());
                    
                    component.set("v.successMsg",'Time entries created Successfully.');
                    component.set("v.successTitle",'Success');
                    component.set("v.displaySuccessModal",true);
                    
                    if(Array.isArray(component.find("successModal"))) {
                        component.find("successModal")[0].open();
                    }else{
                        component.find("successModal").open();
                    }
                    
                    var jsonStr = JSON.stringify(dayList);
                    component.set("v.showSpinner",false);
                    var currentList = JSON.parse(jsonStr);
                    console.log("::::::currentList::::::",currentList);
                    var newListToAdd = [];
                    for(var i = 0;i < currentList.length;i++){
                        if((currentList[i].isNew && currentList[i].hours != null) 
                           || (currentList[i].isUpdated && currentList[i].hours != null)){
                            newListToAdd.push(currentList[i]);
                        }
                    }
                    console.log(':::::newListToAdd:::::',newListToAdd);
                    this.pushNewRowsOnAllDays(component,newListToAdd);
                }else {
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    
                    if(Array.isArray(component.find("successModal"))) {
                        component.find("successModal")[0].open();
                    }else{
                        component.find("successModal").open();
                    }
                }
            });
            $A.enqueueAction(action);
        }else {
            component.set("v.showSpinner",false);
        }
    },
    pushNewRowsOnAllDays: function(component,newList){
        var selectedDate = component.get("v.dateSelected");
        var specificWeekInfo = component.get("v.specificWeekInfo");
        var weekDetails = specificWeekInfo.entryDetails;
        for(var i = 0;i < weekDetails.length;i++){
            if(weekDetails[i].dateVal == selectedDate){
                for(var k = 0;k < newList.length;k++){
                    var pushRec = false;
                    for(var j = 0; j < weekDetails[i].entries.length; j++){
                        if(weekDetails[i].entries[j].chargeCode === newList[k].chargeCode){
                            console.log("entries if");
                            weekDetails[i].entries[j].isUpdated = false;
                            weekDetails[i].entries[j].isNew = false;
                            pushRec = false;
                            break;
                        }else {
                            console.log("entries else");
                            pushRec = true;
                        }
                    }
                    console.log("pushRec",pushRec);
                    if(pushRec){
                        newList[k].isUpdated = false;
                        newList[k].isNew = false;
                        weekDetails[i].entries.push(newList[k]);
                    }
                }
            }else {
                var uniqueSet = [];
                var newListJson = JSON.stringify(newList);
                var newRecordsList = JSON.parse(newListJson);
                for(var k = 0;k < newList.length;k++){
                    newRecordsList[k].isUpdated = false;
                    newRecordsList[k].isNew = false;
                    newRecordsList[k].hours = '';
                    newRecordsList[k].status = '';
                    newRecordsList[k].dayId = '';
                    newRecordsList[k].comments = '';
                    newRecordsList[k].hrschanged = false;
                    newRecordsList[k].dateVal = this.apexDateFormatFunction(weekDetails[i].dateVal);
                    var newKey = newRecordsList[k].projectId+'-'+newRecordsList[k].taskId+'-'+newRecordsList[k].payrollItem+'-'+newRecordsList[k].isBillable+'-'+newRecordsList[k].locationId;
                    
                    var pushRecord = false;
                    for(var j = 0;j < weekDetails[i].entries.length;j++){
                        var key = weekDetails[i].entries[j].projectId+'-'+weekDetails[i].entries[j].taskId+'-'+weekDetails[i].entries[j].payrollItem+'-'+weekDetails[i].entries[j].isBillable+'-'+weekDetails[i].entries[j].locationId;
                        uniqueSet.push(key);
                    }
                    
                    if(uniqueSet.indexOf(newKey) == -1) {
                        var rec = newRecordsList[k];
                        var index = weekDetails[i].entries.length - 1;
                        rec.sequenceNumber = weekDetails[i].entries[index].sequenceNumber + 1;
                        rec.isNew = true;
                        weekDetails[i].entries.push(rec);
                    } 
                }
            }
        }
        console.log(':::::weekDetails:::::',weekDetails);
        specificWeekInfo.entryDetails = weekDetails;
        component.set("v.specificWeekInfo",specificWeekInfo);
        component.set("v.timeDayList",[]);
        
        component.set("v.loadNextWeekData",false);
    },
    projectTaskPopulation: function(component){
        var newRec = component.get("v.newDayRec");
        var wholeTaskList = component.get("v.specificWeekInfo").taskList;
        var contactRec = component.get("v.initialValues").conRec;
        var projects = component.get("v.specificWeekInfo").projectList;
        
        var taskTypeArray = ['Language Training','Interpretation (per hr)','Curriculum Development','Localization','Language Testing','Translation (per hr)','Translation','Preparation time'];
        var nonAdminProjectRTNames = ['EFL_Projects','CD_Projects','Linguist_Support_Projects'];
        var filteredTask = [];
        // Selected Project record
        var projectChoosen = {};
        for(var i = 0;i < projects.length;i++){
            if(projects[i].Id == newRec.projectId)
                projectChoosen = projects[i];
        }        
        //Qry selected project task & contact related contact assingments to filter the project task selection for Linguist Support Projects
        // Added by NS on Nov 30 2018
        var contactAssignments = component.get("v.specificWeekInfo").relatedContactAssign;
        var contactId = component.get("v.initialValues").contactId;
        var conAssign = [];
        var conAssignProjectTaskId = '';
        if(projectChoosen.RecordType.DeveloperName == 'Linguist_Support_Projects'){
            for(var i = 0; i < contactAssignments.length;i++){
                if(contactAssignments[i].Project__c == newRec.projectId && contactAssignments[i].Candidate_Name__c == contactId) {
                    conAssign.push(contactAssignments[i]);
                }
            }
            if(conAssign.length > 0 && conAssign[0].Rate_Card_Rate__c && conAssign[0].Rate_Card_Rate__r.Rate_Type__c == 'Non-SCA CD') {
                conAssignProjectTaskId = conAssign[0].Project_Task__c;
            }
        }
        
        // Filtering task records
        for(var i = 0;i < wholeTaskList.length;i++){
            if(wholeTaskList[i].AcctSeed__Project__c == newRec.projectId && wholeTaskList[i].Name.indexOf('Fringe-Holiday') == -1 
               && contactRec.EE_Pay_Status__c != 'Hourly - PT' && wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName == 'Admin_Projects') {
                
                filteredTask.push(wholeTaskList[i]);
                
            } else if(wholeTaskList[i].AcctSeed__Project__c == newRec.projectId && wholeTaskList[i].Project_Task_Type__c != 'Fringe' 
                      && wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName == 'Admin_Projects'){
                
                filteredTask.push(wholeTaskList[i]);
                
            }else if(wholeTaskList[i].AcctSeed__Project__c == newRec.projectId && taskTypeArray.indexOf(wholeTaskList[i].Project_Task_Type__c) != -1 
                     && ( !wholeTaskList[i].Parent_Project_Task__c || wholeTaskList[i].Name.indexOf('Language Training- Preparation') != -1) 
                     && wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName != 'Admin_Projects' 
                     && nonAdminProjectRTNames.indexOf(wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName) == -1) {
                
                filteredTask.push(wholeTaskList[i]);
                
            }else if(wholeTaskList[i].AcctSeed__Project__c == newRec.projectId 
                     && nonAdminProjectRTNames.indexOf(wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName) != -1) {
                
                // For Linguist Support Project related task filtering
                if(wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName != 'Linguist_Support_Projects'){
                    filteredTask.push(wholeTaskList[i]);
                }else if(wholeTaskList[i].AcctSeed__Project__r.RecordType.DeveloperName == 'Linguist_Support_Projects'){
                    
                    if(conAssignProjectTaskId && wholeTaskList[i].Id == conAssignProjectTaskId){
                        filteredTask.push(wholeTaskList[i]);
                    }else if(!conAssignProjectTaskId){
                        filteredTask.push(wholeTaskList[i]);
                    }
                }
            }
        }
        if(newRec.projectId){
            newRec.ProjectName = projectChoosen.Name;
            newRec.projectRTName = projectChoosen.RecordType.DeveloperName;
        }
        newRec.PayRollItemList = [];
        newRec.payrollItem = '';
        
        if(newRec.projectId && projectChoosen.Training_Location__c) {
            newRec.locationId = projectChoosen.Training_Location__c;
            newRec.locationName = projectChoosen.Training_Location__r.Name;
            newRec.location.push({Id:newRec.locationId,Name:newRec.locationName});
        }else {
            newRec.location = [];
        }
        console.log('::::::filteredTask:::::',filteredTask);
        component.set("v.taskList",filteredTask);
        component.set("v.newDayRec",newRec);
        $A.util.removeClass(component.find("projectTask"),"slds-has-error");
        $A.util.removeClass(component.find("payroll"),"slds-has-error");
    },
    validateProjectTask: function(component){
        var task_PayrollItemMap = component.get("v.task_PayrollItemMap"); 
        var taskList = component.get("v.taskList");
        var newRec = component.get("v.newDayRec");
        var selectedTask;
        var contactAssignments = component.get("v.specificWeekInfo").relatedContactAssign;
        var contactId = component.get("v.initialValues").contactId;
        
        var nonAdminProjectRTNames = ['EFL_Projects','CD_Projects','Linguist_Support_Projects'];
        
        $A.util.removeClass(component.find("payroll"),"slds-has-error");
        
        console.log('enter taskvalidation');
        var payrollItem = '';
        newRec.PayRollItemList = [];
        newRec.payrollItem = '';
        
        if(newRec.taskId) {
            for(var i = 0;i < taskList.length;i++) {
                if(taskList[i].Id == newRec.taskId) {
                    selectedTask = taskList[i].Name;
                    newRec.TaskName = taskList[i].Name;
                    
                    // Remove extra space in between (-) symbol
                    if(newRec.TaskName.indexOf(' - '))
                        newRec.TaskName = newRec.TaskName.split(' - ').join('-');
                    
                    newRec.TaskType = taskList[i].Project_Task_Type__c;
                    newRec.ParentProjectTask = taskList[i].Parent_Project_Task__c;
                    
                    // Get Contact related Cost Rate for Fringe records
                    if(newRec.TaskType == 'Fringe' || newRec.TaskType == 'FMLA' 
                       || newRec.TaskType == 'FMLA Non-Compensatory' || newRec.TaskType == 'Non-Compensatory' 
                       || newRec.TaskType == 'FMLA Compensatory') { 
                        
                        console.log(':::rtyuinbb::::::::::::',task_PayrollItemMap[newRec.TaskName]);
                        if(newRec.TaskType != 'Non-Compensatory' && task_PayrollItemMap[newRec.TaskName]) {
                            
                            newRec.PayRollItemList = task_PayrollItemMap[newRec.TaskName];
                            newRec.payrollItem = newRec.PayRollItemList.length > 0 ? newRec.PayRollItemList[0]:null;
                            
                        }else if((newRec.TaskType == 'Non-Compensatory' || newRec.TaskType == 'FMLA Compensatory') 
                                 && newRec.TaskType != newRec.TaskName && task_PayrollItemMap[newRec.TaskName]) {
                            
                            newRec.PayRollItemList = task_PayrollItemMap[newRec.TaskName];
                            newRec.payrollItem = newRec.PayRollItemList.length > 0 ? newRec.PayRollItemList[0]:null;
                            
                        }else if(newRec.TaskType == 'Non-Compensatory' && newRec.TaskType == newRec.TaskName && task_PayrollItemMap['LWOP']) {
                            newRec.PayRollItemList = task_PayrollItemMap['LWOP'];
                            newRec.payrollItem = newRec.PayRollItemList.length > 0 ? newRec.PayRollItemList[0]:null;
                        }
                        
                    }else if(nonAdminProjectRTNames.indexOf(newRec.projectRTName) != -1 && newRec.TaskType != 'Language Training'
                             && newRec.TaskType != 'Curriculum Development' && newRec.TaskType != 'Linguist Support' && newRec.TaskType != 'Linguist Support Services') {
                        newRec.PayRollItemList = task_PayrollItemMap[newRec.TaskName];
                        newRec.payrollItem = newRec.PayRollItemList.length > 0 ? newRec.PayRollItemList[0]:null;
                    }
                    
                    if(newRec.TaskType == 'ADMINISTRATIVE' && taskList[i].Payroll_Item__c == 'RNB')
                        payrollItem = taskList[i].Payroll_Item__c;
                }
            }
            
            var conAssign = [];
            for(var i = 0; i < contactAssignments.length;i++){
                if(newRec.projectRTName == 'Admin_Projects'){
                    if(contactAssignments[i].Project__c == newRec.projectId && contactAssignments[i].Candidate_Name__c == contactId)
                        conAssign.push(contactAssignments[i]);
                }else if(nonAdminProjectRTNames.indexOf(newRec.projectRTName) != -1){
                    if(contactAssignments[i].Project__c == newRec.projectId && contactAssignments[i].Candidate_Name__c == contactId)
                        conAssign.push(contactAssignments[i]);
                }else {
                    // Language Training Preparation Project Task condition
                    if(newRec.TaskName.indexOf('Language Training- Preparation') == -1){
                        if(contactAssignments[i].Project_Task__c == newRec.taskId 
                           && contactAssignments[i].Candidate_Name__c == contactId) {
                            conAssign.push(contactAssignments[i]);
                        }
                    }else {
                        if(contactAssignments[i].Project_Task__c == newRec.ParentProjectTask && contactAssignments[i].Candidate_Name__c == contactId) {
                            conAssign.push(contactAssignments[i]);
                        }
                    }
                }
            }
            
            if(conAssign.length > 0) {
                if(newRec.TaskType != 'Fringe' && newRec.TaskType != 'FMLA' 
                   && newRec.TaskType != 'FMLA Non-Compensatory' && newRec.TaskType != 'Non-Compensatory'
                  && newRec.TaskType != 'FMLA Compensatory') {
                    if(newRec.projectRTName == 'Admin_Projects' && payrollItem) {
                        newRec.payrollItem = payrollItem;
                    } else {
                        // Below changes for CR billale & non billable payroll item related
                        if(conAssign[0].Rate_Card_Rate__c && conAssign[0].Rate_Card_Rate__c != null) {
                            newRec.PayRollItemList = [];
                            if(conAssign[0].Rate_Card_Rate__r.Payroll_Item__c)
                                newRec.PayRollItemList.push(conAssign[0].Rate_Card_Rate__r.Payroll_Item__c);  
                            if(conAssign[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c)
                                newRec.PayRollItemList.push(conAssign[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c);
                            
                            newRec.prMap = {};
                            if(conAssign[0].Rate_Card_Rate__r.Payroll_Item__c)
                                newRec.prMap[conAssign[0].Rate_Card_Rate__r.Payroll_Item__c] = true; 
                            
                            if(conAssign[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c)
                                newRec.prMap[conAssign[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c] = false;
                        }
                        
                        if(newRec.PayRollItemList && newRec.PayRollItemList.length > 1) {
                            newRec.payrollItem = conAssign[0].Payroll_Item__c;
                        }else {
                            if(newRec.PayRollItemList)
                                newRec.payrollItem = newRec.PayRollItemList[0];
                        }
                    }
                }
                newRec.contactAssignId = conAssign[0].Id;
                if(conAssign[0].Rate_Card_Rate__c && conAssign[0].Rate_Card_Rate__c !== null) {
                    newRec.costRateId = conAssign[0].Rate_Card_Rate__c;
                    newRec.CRRateType = conAssign[0].Rate_Card_Rate__r.Rate_Type__c;
                }
            }
            
            // To hide payroll item selection for all tasks except Fringe-other pay
            if((selectedTask.indexOf('Fringe-Other Pay') != -1 || selectedTask.indexOf('FMLA Compensatory') != -1)
               || newRec.projectRTName != 'Admin_Projects') {
                newRec.disablePayRoll = false;
            } else {
                newRec.disablePayRoll = true;
            }
            
            // Prepopulate values for billable checkbox values based on CR payroll item values
            // To disablebillable check for Non Admin projects based on Cost Rate billable & Non billable Payroll Item values
            if(newRec.projectRTName != 'Admin_Projects') {
                
                if((newRec.projectRTName != 'EFL_Projects' && newRec.projectRTName != 'CD_Projects') 
                   || (newRec.projectRTName == 'EFL_Projects' && newRec.TaskType == 'Language Training')
                   || ((newRec.projectRTName == 'CD_Projects' || newRec.projectRTName == 'Linguist_Support_Projects') && (newRec.TaskType == 'Curriculum Development' || newRec.TaskType == 'Linguist Support' 
                                                                                                                          || newRec.TaskType == 'Linguist Support Services'))) {
                    
                    if(newRec.payrollItem && newRec.PayRollItemList.length > 1)
                        newRec.isBillable = newRec.prMap[newRec.payrollItem];
                    
                    newRec.hidebillableSection = true;
                }else {
                    newRec.isBillable = false;
                    newRec.hidebillableSection = false;
                }
            }else {
                newRec.hidebillableSection = false;
            }  
        }
        component.set("v.newDayRec",newRec);
    },
    dailyPreviousClick: function(component){
        console.log('dailyViewPrevious',component.get("v.dateSelected"));
        component.set("v.showSpinner",true);
        component.set("v.dailyNextIcon",true);
        var selectedDate = component.get("v.dateSelected");
        var dailyDates = component.get("v.specificWeekInfo").weekDates;
        var dateIndex = dailyDates.indexOf(selectedDate) - 1;
        var loadNextWeekData = false;
        if(component.get("v.currWeekIndex") === 0 && dailyDates.indexOf(selectedDate) === 1) {
            component.set("v.dailyPreviousIcon",false);
        }else if(dateIndex < 0) {
            loadNextWeekData = true;
        }
        var dayList = component.get("v.timeDayList");
        var changesMade = false;
        for(var i = 0;i < dayList.length;i++){
            if((dayList[i].isNew && dayList[i].hours && dayList[i].hours != null) 
               || (dayList[i].isUpdated && dayList[i].hours && dayList[i].hours != null)) {
                changesMade = true;
            }
        }
        
        component.set("v.showSpinner",false);
        component.set("v.loadNextWeekData",loadNextWeekData);
        component.set("v.previousIconClick",true);
        component.set("v.nextIconClick",false);
        if(changesMade){
            // show popup to save the changes
            component.set("v.displaySaveAlert",true);
            if(Array.isArray(component.find("saveAlertModal"))) {
                component.find("saveAlertModal")[0].open();
            }else{
                component.find("saveAlertModal").open();
            }
        }else {
            if(component.get("v.displaySaveAlert")) {
                component.set("v.displaySaveAlert",false);
                if(Array.isArray(component.find("saveAlertModal"))) {
                    component.find("saveAlertModal")[0].close();
                }else{
                    component.find("saveAlertModal").close();
                }
            }
            if(!loadNextWeekData) {
                component.set("v.dateSelected",dailyDates[dateIndex]);
                this.getSpecificDateInformation(component);
            }else {
                var setEvent = component.getEvent("entryDetailEvent");
                setEvent.setParams({"typeOfAction":"Previous"});
                setEvent.fire();
            }
        }
    },
    dailyNextClick: function(component){
        console.log('dailyViewNext',component.get("v.dateSelected"));
        component.set("v.showSpinner",true);
        component.set("v.dailyPreviousIcon",true);
        var selectedDate = component.get("v.dateSelected");
        var dailyDates = component.get("v.specificWeekInfo").weekDates;
        var dateIndex = dailyDates.indexOf(selectedDate) + 1;
        var loadNextWeekData = false;
        if(component.get("v.currWeekIndex") === 8 && dailyDates.indexOf(selectedDate) === 5){
            component.set("v.dailyNextIcon",false);
        }else if(dateIndex > 6) {
            loadNextWeekData = true;
        }
        var dayList = component.get("v.timeDayList");
        var changesMade = false;
        for(var i = 0;i < dayList.length;i++){
            if((dayList[i].isNew == true && dayList[i].hours && dayList[i].hours != null) 
               || (dayList[i].isUpdated == true && dayList[i].hours && dayList[i].hours != null)) {
                console.log('::::i:::',i);
                console.log(dayList[i].isUpdated,dayList[i].hours);
                changesMade = true;
            }
        }
        component.set("v.showSpinner",false);
        component.set("v.loadNextWeekData",loadNextWeekData);
        component.set("v.nextIconClick",true);
        component.set("v.previousIconClick",false);
        console.log("changesMade",changesMade);
        if(changesMade){
            // show popup to save the changes
            component.set("v.displaySaveAlert",true);
            if(Array.isArray(component.find("saveAlertModal"))) {
                component.find("saveAlertModal")[0].open();
            }else{
                component.find("saveAlertModal").open();
            }
            
        }else {
            if(component.get("v.displaySaveAlert")) {
                component.set("v.displaySaveAlert",false);
                if(Array.isArray(component.find("saveAlertModal"))) {
                    component.find("saveAlertModal")[0].close();
                }else{
                    component.find("saveAlertModal").close();
                }
            }
            if(!loadNextWeekData) {
                component.set("v.dateSelected",dailyDates[dateIndex]);
                this.getSpecificDateInformation(component);
            }else {
                var setEvent = component.getEvent("entryDetailEvent");
                setEvent.setParams({"typeOfAction":"Next"});
                setEvent.fire();
            }
        }
    }
})