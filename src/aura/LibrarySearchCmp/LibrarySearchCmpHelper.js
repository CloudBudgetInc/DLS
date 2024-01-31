({	    
 
    setInitialValues : function(cmp){
        var displayObj = {};
        displayObj.searchEnabled = false;
        displayObj.materialRecordsCnt = 0;
        displayObj.materialTotalCol1 = 0;
        displayObj.materialTotalCol2 = 0;
        
        var filterObj = {};
        filterObj.searchText = "";
        filterObj.searchLanguageList = [];
        filterObj.contentType = "All";
        filterObj.format = "All";
        filterObj.language = "All";
        filterObj.sortingOption = "Most Requested";
        filterObj.viewOption = "Icon";
        filterObj.bookSeries = "All";
        filterObj.dlsSection = "All";
        filterObj.dateRangeSelected = "All";
        filterObj.seletedRating = "All";
        filterObj.pageSize = 15;
        filterObj.pageNumber = 1;
        
        var filterValues = {};
        filterValues.sortingOptionsList = ["Most Requested","Top Rated","Most Favorited","Newest","Alphabetical"];
        
        //Changes made for W-005440 - To add filters in the query string in apex controller
        filterValues.ratingOptions = ["All","4+","3+","2+","0-1"];
        filterValues.dateRangeOptions = ["All","Last 7 Days","Last 30 Days","Last 60 Days","Last 90 Days","Last 120 Days","Last 365 Days"];        
        filterValues.paginationNumbering = [15,30,45];

        filterValues.dlsSectionOptions = [];
        filterValues.bookSeriesList = [];
        
        cmp.set("v.filterValues",filterValues);
        cmp.set("v.displayObj",displayObj);
        
        if(!cmp.get("v.fromDetail")){
            cmp.set("v.filterObj",filterObj);
        }
    },
    getCurrentUserInfo : function(cmp,event) {
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCurrentUserType');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = response;
                console.log('result:::::::',result);
                cmp.set("v.userType",result);
                cmp.set("v.showSpinner",false);
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
    getInitialFilterValues : function(cmp,event){
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getFilterValues');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result:::::::',result);
                var filterValues = cmp.get("v.filterValues");
                filterValues.formatList = result.formatValues;
                filterValues.languageList = result.languageValues;
                filterValues.bookSeriesList = result.seriesValues;
                
                filterValues.formatList.unshift({'label':'All','value':'All'});
                filterValues.languageList.unshift({'label':'All','value':'All'});
                filterValues.bookSeriesList.unshift({label:'All',value:'All'});
                
                cmp.set("v.filterValues",filterValues);
                
                if(cmp.get("v.fromDetail")){
                    self.getSearchInputs(cmp, event);
                }
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                cmp.set("v.showSpinner",false);
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
    getSearchInputs : function(cmp, event){
        var filter = cmp.get("v.filterObj");
        var userType = cmp.get("v.userType");
        let ratingOptions = {
                        "All": "All", 
                        "4+": " AND Average_Rating__c >= 4",
                        "3+": " AND Average_Rating__c >= 3 AND Average_Rating__c < 4",
                        "2+": " AND Average_Rating__c >= 2 AND Average_Rating__c < 3",
                        "0-1": " AND Average_Rating__c >= 0 AND Average_Rating__c < 2"
        },
        dateRangeOptions = {
                            "All": "All",
                            "Last 7 Days": " AND Date__c >= LAST_N_DAYS:7",
                            "Last 30 Days": " AND Date__c >= LAST_N_DAYS:30",
                             "Last 60 Days": " AND Date__c >= LAST_N_DAYS:60",
                             "Last 90 Days": " AND Date__c >= LAST_N_DAYS:90",
                             "Last 120 Days": " AND Date__c >= LAST_N_DAYS:120",
                             "Last 365 Days": " AND Date__c >= LAST_N_DAYS:365"
        };
        var inputText = filter.searchText;
        var fileType = filter.format;
        var objectType = filter.contentType;
        var dlsSection = filter.dlsSection;
        var bookSeries = filter.bookSeries;
        var rating = ratingOptions[filter.seletedRating];
        var dateRange = dateRangeOptions[filter.dateRangeSelected];
        var language = filter.language;
        var pageNumber = null;
        var pageSize = null;
        

            if(filter.searchLanguageList.length > 0){
                language = filter.searchLanguageList[0].Id;
            }else{
                language = '';
            }
        if( userType == 'Instructor' || userType == 'Student') {
            if(filter.pageNumber) {
                pageNumber = parseInt(filter.pageNumber);
            }
            if(filter.pageSize) {
                pageSize = parseInt(filter.pageSize);
            }
        }
        
        console.log(inputText,language,fileType,objectType,dlsSection,bookSeries,rating,dateRange,pageNumber,pageSize);
        if(inputText){
            if(objectType == 'Digital Copy') {
                console.log('Enter digital copy');
                this.contentQryWithSearchText(cmp,event,inputText,language,fileType,bookSeries,dlsSection,pageNumber,pageSize);
            }else if(objectType == 'Hard Copy') {
                console.log('Hard Copy');
                this.materialQryWithSearchText(cmp,event,inputText,language,fileType,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize);
            }else if(objectType == 'All') {
                console.log('All');
                //this.contentQryWithSearchText(cmp,event,inputText,language,fileType,bookSeries,dlsSection);
                this.materialQryWithSearchText(cmp,event,inputText,language,fileType,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize);
            }
        }else {
            if(objectType == 'Digital Copy') {
                console.log('Enter digital copy1');
                this.contentQryWithoutSearchText(cmp,event,language,fileType,bookSeries,dlsSection,pageNumber,pageSize); 
            }else if(objectType == 'Hard Copy') {
                console.log('Hard Copy1');
                this.materialQryWithoutSearchText(cmp,event,language,fileType,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize); 
            }else if(objectType == 'All') {
                console.log('All1');
                this.materialQryWithoutSearchText(cmp,event,language,fileType,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize); 
            }
        }
        
        var showMobileViewFilterModel = cmp.get("v.showMobileViewFilterModel");
        if(showMobileViewFilterModel){
            cmp.set("v.tabName","myMaterials");
            cmp.set("v.showMobileViewFilterModel",false);
        }
    },
    contentQryWithSearchText : function(cmp, event,inputText,language,fileFormat,bookSeries,dlsSection,pageNumber,pageSize){
        var self = this;
        var param = {};
        param.SearchString = inputText;
        param.language = language;
        param.filetype = fileFormat;
        param.bookseries = bookSeries;
        param.dlsSection = dlsSection;
        param.pageNumber = pageNumber;
        param.pageSize = pageSize;
        param.sortingOption = cmp.get("v.filterObj").sortingOption;
        
        cmp.set("v.wholeContents",[]);
        cmp.set("v.displayContents",[]);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getDigitalContentsByText');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('content::search::result:::',result);
                cmp.set("v.wholeContents",result.contentRecords);
                cmp.set("v.displayContents",result.contentRecords);
                self.displayResults(cmp,result);
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
    materialQryWithSearchText : function(cmp, event,inputText,language,format,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize){
        var self = this;
        var param = {};
        param.SearchString = inputText;
        param.language = language;
        param.filetype = format;
        param.bookseries = bookSeries;
        param.dlsSection = dlsSection;
        param.rating = rating;
        param.dateRange = dateRange;
        param.pageNumber = pageNumber;
        param.pageSize = pageSize;
        param.sortingOption = cmp.get("v.filterObj").sortingOption;
        
        cmp.set("v.wholeMaterials",[]);
        cmp.set("v.displayMaterials",[]);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getMaterialsByText');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('material::search::result:::',result);
                cmp.set("v.wholeMaterials",result.materialRecords);
                cmp.set("v.displayMaterials",result.materialRecords);
                self.displayResults(cmp,result);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    contentQryWithoutSearchText : function(cmp, event,language,fileFormat,bookSeries,dlsSection,pageNumber,pageSize){
        var self = this;
        var param = {};
        param.language = language;
        param.filetype = fileFormat;
        param.bookseries = bookSeries;
        param.dlsSection = dlsSection;
        param.sortingOption = cmp.get("v.filterObj").sortingOption; 
        param.pageNumber = pageNumber;
        param.pageSize = pageSize;
        cmp.set("v.wholeContents",[]);
        cmp.set("v.displayContents",[]);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getDigitalContentsWithoutText');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('content::search:2:result:::',result);
                cmp.set("v.wholeContents",result.contentRecords);
                cmp.set("v.displayContents",result.contentRecords);
                self.displayResults(cmp,result);
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
    materialQryWithoutSearchText : function(cmp, event,language,format,bookSeries,dlsSection,rating,dateRange,pageNumber,pageSize){
        var self = this;
        var param = {};
        param.language = language;
        param.filetype = format;
        param.bookseries = bookSeries;
        param.dlsSection = dlsSection;
        param.rating = rating;
        param.dateRange = dateRange;
        param.pageNumber = pageNumber;
        param.pageSize = pageSize;
        param.sortingOption = cmp.get("v.filterObj").sortingOption;
        
        console.log(':::::::param::::',JSON.stringify(param));
        cmp.set("v.wholeMaterials",[]);
        cmp.set("v.displayMaterials",[]);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getMaterialsWithoutText');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('material::search::result:::',result);
                cmp.set("v.wholeMaterials",result.materialRecords);
                cmp.set("v.displayMaterials",result.materialRecords);
                self.displayResults(cmp,result);
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
    displayResults : function(cmp, result){
		var filterValues = cmp.get("v.filterValues");
        var displayMaterials = cmp.get("v.displayMaterials");
        
        if(result.formatValues){
            filterValues.formatList = result.formatValues;
        }
        filterValues.languageList = result.languageValues;
        filterValues.bookSeriesList = result.seriesValues;
        filterValues.dlsSectionOptions = result.dlsSectionValues;
        
        filterValues.formatList.unshift({label:'All',value:'All'});
        filterValues.languageList.unshift({label:'All',value:'All'});
        filterValues.bookSeriesList.unshift({label:'All',value:'All'});
        filterValues.dlsSectionOptions.unshift({label:'All',value:'All'});
        
        var filterObj = cmp.get("v.filterObj");
        
        if(filterObj.bookSeries == null || filterObj.bookSeries == 'All'){
            filterObj.bookSeries = filterValues.bookSeriesList[0].value;
        }
        
        if(filterObj.language == null || filterObj.language == 'All'){
            filterObj.language = filterValues.languageList[0].value;
        }
        
        if(filterObj.format == null || filterObj.format == 'All'){
            filterObj.format = filterValues.formatList[0].value;
        }
        
        if(filterObj.dlsSection == null || filterObj.dlsSection == 'All'){
            filterObj.dlsSection = filterValues.dlsSectionOptions[0].value;
        }
        
        if(cmp.get("v.displayContents").length > 0 || cmp.get("v.displayMaterials").length > 0){
            var displayObj = cmp.get("v.displayObj");
            displayObj.displaySearchResult = true;
            
            if(result.materialCVRecordsCnt){
                displayObj.materialRecordsCnt = result.materialCVRecordsCnt;
            }else{
                displayObj.materialRecordsCnt = 0;
            }

            if(filterObj.pageSize && displayMaterials.length > 0 && filterObj.pageNumber){
                if(filterObj.pageSize > displayMaterials.length){
                    displayObj.materialTotalCol2 = (filterObj.pageNumber - 1) * filterObj.pageSize + displayMaterials.length;
                }else{
                    displayObj.materialTotalCol2 = filterObj.pageNumber * filterObj.pageSize;
                }
                
                displayObj.materialTotalCol1 = (filterObj.pageNumber - 1) * filterObj.pageSize + 1; 
            }else{
                displayObj.materialTotalCol1 = 0;
                displayObj.materialTotalCol2 = 0;
            }

            cmp.set("v.displayObj",displayObj);
        }
        
        //cmp.set("v.filterValues",filterValues);
        //cmp.set("v.filterObj",filterObj);
        cmp.set("v.showSpinner",false);
    },
    filterMaterialsByRating : function(cmp){
        var wholeMaterials = cmp.get("v.wholeMaterials");
        var avgRating = cmp.get("v.filterObj").seletedRating;
        var filteredMaterials = [];
                
        for(var i = 0;i < wholeMaterials.length;i++){
            if(wholeMaterials[i].Average_Rating__c){
            	if(avgRating == '4+' && wholeMaterials[i].Average_Rating__c >= 4){
                    filteredMaterials.push(wholeMaterials[i]);
                }else if(avgRating == '3+' && wholeMaterials[i].Average_Rating__c >= 3){
                    filteredMaterials.push(wholeMaterials[i]);
                }else if(avgRating == '2+' && wholeMaterials[i].Average_Rating__c >= 2){
                    filteredMaterials.push(wholeMaterials[i]);
                }else if(avgRating == '0-1' && wholeMaterials[i].Average_Rating__c >= 0){
                    filteredMaterials.push(wholeMaterials[i]);
                }    
            }
        }  
        cmp.set("v.displayMaterials",filteredMaterials);
        cmp.set("v.showSpinner",false);
    },
    filterMaterialsByDateRange : function(cmp){
        var wholeMaterials = cmp.get("v.wholeMaterials");
        var dateRange = cmp.get("v.filterObj").dateRangeSelected;
        var filteredMaterials = [];

        for(var i = 0;i < wholeMaterials.length;i++){
            if(dateRange == 'Last 7 Days'){
                var calculatedDt = moment().subtract(7, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }else if(dateRange == 'Last 30 Days'){
                var calculatedDt = moment().subtract(30, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }else if(dateRange == 'Last 60 Days'){
                var calculatedDt = moment().subtract(60, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }else if(dateRange == 'Last 90 Days'){
                var calculatedDt = moment().subtract(90, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }else if(dateRange == 'Last 120 Days'){
                var calculatedDt = moment().subtract(120, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }else if(dateRange == 'Last 365 Days'){
                var calculatedDt = moment().subtract(365, 'days').calendar();
                var dt = wholeMaterials[i].Date__c;
                if(moment(dt).isSame(calculatedDt) || moment(dt).isAfter(calculatedDt)){
                    filteredMaterials.push(wholeMaterials[i]);
                }
            }
        }
        cmp.set("v.displayMaterials",filteredMaterials);
        cmp.set("v.showSpinner",false);
    },
})