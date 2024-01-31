({
    getFilterInformations : function(component) {
        var action = component.get("c.getFilterRelatedInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log(':::result:::::::getFilterInformations::::::::::',result);
                
                // Filter informations
                var FLP = ['Native','5/5','4/4','3/3','2/2','1/1'];
                var ELP = ['5/5','4/4','3/3','2/2','1/1'];
                
                var langLabelList = [];
                
                //For showing language labels as multiselect
                for(var i = 0;i < result.langList.length;i++){
                    langLabelList.push(result.langList[i].Name);
                }
                component.set("v.languageLabelList",langLabelList);
                
                component.set("v.serviceList",result.serviceList);
                component.set("v.skillRatingList",result.skillRating);
                component.set("v.degreesList",result.degrees);
                component.set("v.dlsRating",result.dlsRating);
                component.set("v.citizenshipList",result.citizenship);
                component.set("v.countryOfBirth",result.countryOfBirth);
                component.set("v.languageList",result.langList);
                component.set("v.locationList",result.locations);
                component.set("v.timeList",result.timeList);
                component.set("v.foreignLangList",FLP);
                component.set("v.englishLangList",ELP);
                component.set("v.instructorStatusList",result.instructorStatus);
                component.set("v.userList",result.userList);
                var obj = {};
                obj.selectedLanguage = [];
                obj.selectedService = [];
                obj.selectedSkillRating = [];
                obj.selectedDegree = [];
                obj.selectedDlsRating = [];
                obj.selectedForeignProficiency = [];
                obj.selectedEnglishProficiency = [];
                obj.selectedCitizenship = [];
                obj.selectedInstructorStatus = [];
                obj.monday = false;
                obj.tuesday = false;
                obj.wednesday = false;
                obj.thursday = false;
                obj.friday = false;
                obj.selectedlocation = [];
                obj.selectedBookmark = [];
                obj.dliQualified = false;
                component.set("v.search",obj);
                component.set("v.displayMultiSelectFilters",true);
                //Call parent information details method to populate the language value
                this.getParentValuesBasedonURL(component);
                
                var self = this;
                window.setTimeout(
                    $A.getCallback(function() {
                        self.initializeTable(component);
                    }),200);
            }
        });
        $A.enqueueAction(action);
    },
    initializeTable : function(cmp){
        var header = [
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                'target':'_blank'
            },
            {
                'label':'Native Language',
                'name':'NativeLanguages',
                'type':'text'
            },
            {
                'label':'Language 2',
                'name':'Language_2__c',
                'type':'text'
            },
            {
                'label':'DLS Candidate Rating',
                'name':'DLS_Candidate_Rating__c',
                'type':'text'
            },
            {
                'label':'Hourly Rate' ,
                'name':'HourlyCost',
                'type':'text',
                'truncate' : {
                    "characterLength" : 20
                }
            },
            {
                'label':'# of Active Projects',
                'name':'Active_Count_as_Instructor__c',
                'type':'number'
            },
            {
                'label':'Proximity',
                'name':'Proximity__c',
                'type':'number'
            },
            {
                'label':'Instructor Status',
                'name':'Instructor_Status__c',
                'type':'text'
            },
            {
                'label':'Until',
                'name':'Next_Availability__c',
                'type':'Date',
                'format':'MM/DD/YYYY'
            },
            {
                'label':'Availability Notes',
                'name':'Availability__c',
                'type':'richtext',
                'truncate' : {
                    "characterLength" : 80,
                    "showLessLabel" : '...less',
                    "showMoreLabel" : '...more'
                }
            },
            {
                'label':'Candidate Notes',
                'name':'Candidate_Notes__c',
                'type':'richtext',
                'truncate' : {
                    "characterLength" : 80,
                    "showLessLabel" : '...less',
                    "showMoreLabel" : '...more'
                }
            }
        ];
        
        cmp.set("v.header",header);
        var imgUrl = $A.get('$Resource.Bookmark_Icon');
        var imgUrl1 = $A.get('$Resource.SLDS_2_1_3') + '/assets/icons/utility/threedots_60.png';
        
        var tableConfig = {
            
            "rowAction":[
                {
                    'label': '',
                    'type':'image',
                    'id':'bookMark',
                    'src': imgUrl,
                    'visible': true
                },
                {
                    'label': '',
                    'type':'image',
                    'id':'moreClick',
                    'src': imgUrl1,
                    'visible': true
                }	
            ]
        };
        cmp.set("v.taskTableConfig",tableConfig);
        cmp.set("v.showSpinner",false);
        if(!cmp.get("v.search").selectedLanguage && cmp.get("v.search").selectedBookmark.length == 0){
            cmp.set("v.infoMessage",'Please Choose any Language or Bookmark User.');
            cmp.set("v.showInfoWindow",true);
        }else {
            if(cmp.get("v.contactsList").length > 0) {
                cmp.find("contactTable").initialize();
            }
        }
    },
    getFilteredContacts: function(component){
        var search = component.get("v.search");
        //Location
        var locationId;
        if(search.selectedlocation != null && search.selectedlocation.length > 0){
            locationId = search.selectedlocation[0].Id;
        }
        var experience = search.enteredExperience?search.enteredExperience:null;
        var zip = search.enteredZip?search.enteredZip:null;
        var proximity = search.enteredProximity?parseInt(search.enteredProximity):0;
        
        // Bookmarked User
        var bookmarkUsrId;
        if(search.selectedBookmark != null && search.selectedBookmark.length > 0){
            bookmarkUsrId = search.selectedBookmark[0].Id;
        }
        
        //get Language Name quivalent ids for search
        var languageIds = [];
        var languageList = component.get("v.languageList");
        var selectedLangs = search.selectedLanguage;
        for(var i = 0;i < languageList.length;i++){
            if(selectedLangs.indexOf(languageList[i].Name) != -1){
                languageIds.push(languageList[i].Id);
            }
        }
        console.log('::::::::languageIds::::',languageIds);
        var bundleId = null;
        var searchParameter = {
            service: search.selectedService,
            candidateRating: search.selectedDlsRating,
            languageIds: languageIds,
            experience: search.enteredExperience,
            degree: search.selectedDegree,
            zip: search.enteredZip,
            proximity: proximity,
            foreignProficiency: search.selectedForeignProficiency,
            englishProficiency: search.selectedEnglishProficiency,
            isVerified: false,
            bundleId: bundleId,
            locationId: locationId,
            searchByName: null,
            citizenshipValues: search.selectedCitizenship,
            countryOfbirth: search.selectedCountryOfBirth,
            skillRating: search.selectedSkillRating,
            instructorStatus: search.selectedInstructorStatus,
            availabilityDate: search.selectedAvailabilityDate,
            bookmarkedUserId: bookmarkUsrId,
            dliQualified: search.dliQualified
        };
        
        var conflictSearchParameter = {
            startDate: search.selectedStartDate,
            endDate: search.selectedEndDate,
            startTime: search.selectedStartTime != '--None--' ? search.selectedStartTime : null,
            endTime: search.selectedEndTime != '--None--' ? search.selectedEndTime : null,
            monday: search.monday,
            tuesday: search.tuesday,
            wednesday: search.wednesday,
            thursday: search.thursday,
            friday: search.friday,
            saturday: search.saturday,
            sunday: search.sunday
        };
        var isConflictCheckNeed = false;
        if(conflictSearchParameter.startDate && conflictSearchParameter.startTime && conflictSearchParameter.endDate && conflictSearchParameter.endTime) {
            isConflictCheckNeed = true;
        }
        
        var action = component.get("c.getAllInstructors");
        action.setParams({
            'isConflictSearch': isConflictCheckNeed,
            'conflictSearchJSon': JSON.stringify(conflictSearchParameter),
            'parametersJson': JSON.stringify(searchParameter)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log(':::result:::::::search::click::::::::',result);
                component.set("v.contactsList",this.tagformation(result.instructors));
                component.set("v.scoreMap",result.instructorScore);
                component.set("v.conflictMap",result.conflictCount);
                this.initializeTable(component);
                component.set("v.showSpinner",false);
            }else {
                console.log(response.getError()[0].message);
                component.set("v.infoMessage",response.getError()[0].message);
                component.set("v.showInfoWindow",true);
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    tagformation: function(instructorList){
        for(var i = 0; i < instructorList.length; i++) {
            //Get languages from the contact to displayed as a tag.
            if(instructorList[i].Known_Languages__r) {
                instructorList[i].tags = [];
                instructorList[i].NativeLanguages = '';
                var knownLanArray = instructorList[i].Known_Languages__r.records;
                for(var j = 0; j < knownLanArray.length; j++) {
                    if(knownLanArray[j].Language__r && knownLanArray[j].Language__r.Name) {
                        if(instructorList[i].tags.indexOf(knownLanArray[j].Language__r.Name) == -1) {
                            instructorList[i].tags.push(knownLanArray[j].Language__r.Name);
                        }
                        
                        if(knownLanArray[j].Native_Language__c){
                            if(!instructorList[i].NativeLanguages){
                                instructorList[i].NativeLanguages = knownLanArray[j].Language_Name__c;
                            }else {
                                instructorList[i].NativeLanguages += ', \n'+ knownLanArray[j].Language_Name__c;
                            }
                        }
                    }
                }
            }
            
            if(instructorList[i].Cost_Rates__r){
                var costRateArray = instructorList[i].Cost_Rates__r.records;
                instructorList[i].HourlyCost = '';
                for(var j = 0; j < costRateArray.length; j++) {
                    if(costRateArray[j].Rate_Type__c && costRateArray[j].Fully_Loaded_Rate__c) {
                        if(!instructorList[i].HourlyCost) {
                            instructorList[i].HourlyCost = costRateArray[j].Rate_Type__c+' - $'+costRateArray[j].Fully_Loaded_Rate__c;
                        }else {
                            instructorList[i].HourlyCost += ', \n'+costRateArray[j].Rate_Type__c+' - $'+costRateArray[j].Fully_Loaded_Rate__c;
                        }
                    }
                }
                //console.log(':::::::instructorList::::',instructorList[i]);
            }
            
        }
        return instructorList;
    },
    displayMoreInfoDetails: function(component, instructor){
        component.set("v.showSpinner",true);
        // Get contact related skills, Experience,Language Testing & Schedule information 
        var action = component.get("c.getContactChildRecords");
        action.setParams({'contactId' : instructor.Id});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                console.log('::::::::result:::::',result);
                this.moreInfoRecordsFormation(component,result,instructor);
            }
            
        });
        $A.enqueueAction(action);
    },
    moreInfoRecordsFormation : function(component, result,instructor){
        var contactsList = component.get("v.contactsList");
        var selectedContact;
        for(var i = 0;i < contactsList.length;i++){
            if(contactsList[i].Id == instructor.Id){
                selectedContact = contactsList[i];
            }
        }
        
        var scoreMap = component.get("v.scoreMap");
        if(scoreMap.hasOwnProperty(selectedContact.Id)){
            selectedContact.score = scoreMap[selectedContact.Id];
        }else {
            selectedContact.score = 0;
        }
        var conflictMap = component.get("v.conflictMap");
        if(conflictMap){
            selectedContact.conflictCount = conflictMap[selectedContact.Id];
        }else {
            selectedContact.conflictCount = 0;
        }
        
        var education = [];
        var experience = [];
        var experienceRecords = [];
        if(result.experienceRecords)
            experienceRecords = result.experienceRecords;
        
        for(var i = 0;i < experienceRecords.length;i++){
            if(experienceRecords[i].RecordType.DeveloperName == 'Professional_Work_Experience') {
                experience.push(experienceRecords[i]);
            }else if(experienceRecords[i].RecordType.DeveloperName == 'Education_Experience') {
                var address = experienceRecords[i].City__c+', '+experienceRecords[i].State__c+', '+experienceRecords[i].Country__c;
                experienceRecords[i].Address = address;
                education.push(experienceRecords[i]);
            }
        }
        
        component.set("v.contactRec",selectedContact);
        if(instructor.Known_Languages__r != null)
            component.set("v.languageDetails",selectedContact.Known_Languages__r.records);
        
        if(instructor.Cost_Rates__r != null)
            component.set("v.costRateDetails",selectedContact.Cost_Rates__r.records);
        
        if(result.scheduleRecords)
            component.set("v.scheduleDetails",result.scheduleRecords);
        
        // header & field names formation for all more info tabs
        //Language tab
        var langFieldDetails = [{'label':'Language Name','Name':'Language_Name__c','type':'reference','value':'Language__c'},
                                {'label':'Native Language','Name':'Native_Language__c','type':'checkbox','value':''},
                                {'label':'Speaking Proficiency','Name':'Speaking_Proficiency__c','type':'text','value':''},
                                {'label':'Listening Proficiency','Name':'Listening_Proficiency__c','type':'text','value':''}];
        // Experience
        var expFieldDetails = [{'label':'Name','Name':'Name','type':'reference','value':'Id'},
                               {'label':'Company Name','Name':'Name_of_Company__c','type':'text','value':''},
                               {'label':'Role/Title','Name':'Role_Title__c','type':'text','value':''},
                               {'label':'Services','Name':'Services__c','type':'picklist','value':''},
                               {'label':'Exp.in Months','Name':'Experience_in_Months__c','type':'number','value':''},
                               {'label':'Exp.in Years','Name':'Experience_in_Years__c','type':'number'},
                               {'label':'Total # of Hours','Name':'Total_Hours_Performed__c','type':'text','value':''}];
        
        // Education
        var educateFieldDetails = [{'label':'Name','Name':'Name','type':'reference','value':'Id'},
                                   {'label':'College/School','Name':'College_School__c','type':'text','value':''},
                                   {'label':'School Type','Name':'College_School_Type__c','type':'picklist','value':''},
                                   {'label':'Degree','Name':'Degree__c','type':'text','value':''},
                                   {'label':'Degree Level','Name':'Degree_Level__c','type':'picklist','value':''},
                                   {'label':'Year of Completion','Name':'Year_of_Completion__c','type':'text','value':''},
                                   {'label':'Address','Name':'Address','type':'text','value':''}];
        
        // Cost Rate
        var crFieldValues = [{'label':'Name','Name':'Name','type':'reference','value':'Id'},
                             {'label':'Rate Type','Name':'Rate_Type__c','type':'picklist','value':''},
                             {'label':'Effective Date','Name':'Effective_Date__c','type':'date','value':''},
                             {'label':'Pay Type','Name':'Pay_Type__c','type':'picklist','value':''},
                             {'label':'Pay Frequency','Name':'Pay_Frequency__c','type':'text','value':''},
                             {'label':'Payroll Item','Name':'Payroll_Item__c','type':'picklist','value':''},
                             {'label':'Tax Type','Name':'Tax_Type__c','type':'picklist','value':''},
                             {'label':'Hourly Cost','Name':'AcctSeed__Hourly_Cost__c','type':'currency','value':''},
                             {'label':'OverTime Rate','Name':'OverTime_Rate__c','type':'currency','value':''},
                             {'label':'Fully Loaded Rate','Name':'Fully_Loaded_Rate__c','type':'currency','value':''},
                             {'label':'H W Rate','Name':'H_W_Rate__c','type':'currency','value':''},
                             {'label':'VAC Rate','Name':'VAC_Rate__c','type':'currency','value':''},
                             {'label':'HOL Rate','Name':'HOL_Rate__c','type':'currency','value':''},
                             {'label':'SCA Type','Name':'SCA_Type__c','type':'picklist','value':''},
                             {'label':'Holiday Pay Type','Name':'Holiday_Pay_Type__c','type':'picklist','value':''},
                             {'label':'HOL Rate + VAC Rate','Name':'HOL_Rate_VAC_Rate__c','type':'currency','value':''}];
        
        // Schedule
        var scheduleField = [{'label':'Name','Name':'Name','type':'reference','value':'Id'},
                             {'label':'Start Date','Name':'Start_Date__c','type':'date','value':''},
                             {'label':'End Date','Name':'End_Date__c','type':'date','value':''},
                             {'label':'Start Time','Name':'Start_Time__c','type':'picklist','value':''},
                             {'label':'End Time','Name':'End_Time__c','type':'picklist','value':''},
                             {'label':'Days','Name':'Days__c','type':'text','value':''},
                             {'label':'Hours/Week','Name':'Hours_Week__c','type':'number','value':''}];
        
        
        component.set("v.educationDetails",education);
        component.set("v.experienceDetails",experience);
        //console.log("experience:::::",component.get("v.experienceDetails"));
        component.set("v.langFieldDetails",langFieldDetails);
        component.set("v.expFieldDetails",expFieldDetails);
        component.set("v.educationFieldDetails",educateFieldDetails);
        component.set("v.crFieldDetails",crFieldValues);
        component.set("v.scheduleFieldDetails",scheduleField);
        
        component.set("v.displayMoreInfoModal",true);
        component.set("v.showSpinner",false);
    },
    bookMarkDetails: function(component, instructor){
        var bookmarkUsrId = '';
        var search = component.get("v.search");
        if(search.selectedBookmark != null && search.selectedBookmark.length > 0){
            bookmarkUsrId = search.selectedBookmark[0].Id;
        }
        var action = component.get("c.getBookmarkDetails");
        action.setParams({
            contactId : instructor.Id,
            "userId" : bookmarkUsrId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                if(result.length > 0){
                    component.set("v.bookMarkTitle",'Manage Bookmark');
                }else {
                    component.set("v.bookMarkTitle",'Create Bookmark');
                }
                component.set("v.contactRec",instructor);
                component.set("v.displayBookMarkSection",true);
            }else {
                console.log(response.getError()[0].message);
                component.set("v.infoMessage",response.getError()[0].message);
                component.set("v.showInfoWindow",true);
            }
        });
        $A.enqueueAction(action);
    },
    getParentValuesBasedonURL : function(cmp){
        
        var urlObj = this.getValuesfromUrl(cmp);
        cmp.set("v.parentId",urlObj.parentId);
        cmp.set("v.parentType",urlObj.parentType);
        var action = cmp.get("c.getParentInformation");
        action.setParams({
            "parentId" : cmp.get("v.parentId"),
            "parentType" : cmp.get("v.parentType")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log(":::::result::::",result);
                if(result.length > 0){
                    var searchObj = cmp.get("v.search");
                    searchObj.selectedLanguage = result[0].Id;
                    cmp.set("v.search",searchObj);
                }
                this.getFilteredContacts(cmp);
            }else {
                console.log(':::parentinformation::::error:::::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getValuesfromUrl : function(cmp){
        var regex = /[?&]([^=#]+)=([^&#]*)/g,
            url = window.location.href,
            params = {},
            match;
        console.log(regex.exec(url));
        while(match = regex.exec(url)) {
            params[match[1]] = match[2];
        }
        console.log('::::params::::',params);
        return params;
    }
})