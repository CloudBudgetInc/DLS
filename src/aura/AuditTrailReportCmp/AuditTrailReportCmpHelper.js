({
    applyFilter : function(component, event, helper){
        
        var filterObj = component.get("v.filterObj");
        
        var fromDate = filterObj.fromDateVal || null;
        var toDate = filterObj.toDateVal || null;
        var insName = '';
        var userName = '';
        var projName = '';
        
        if(filterObj && filterObj.selectedConName && filterObj.selectedConName.length > 0 && filterObj.selectedConName[0].Name){
            insName = filterObj.selectedConName[0].Name;
        }
        if(filterObj && filterObj.selectedUser && filterObj.selectedUser.length > 0 && filterObj.selectedUser[0].Name){
            userName = filterObj.selectedUser[0].Name;
        }
        if(filterObj && filterObj.selectedProjName && filterObj.selectedProjName.length > 0 && filterObj.selectedProjName[0].Name){
            projName = filterObj.selectedProjName[0].Name;
        }
        var param = {};
        param.fromDate = fromDate;
        param.toDate = toDate;
        param.insName = insName;
        param.userName = userName;
        param.projName = projName;
        
        var self = this;
        const server = component.find('server');
        const action = component.get('c.getAuditReportRecs');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) {                
                var result = response;
                component.set("v.tcdHistoryRecs", result);
                component.set("v.spinner", false);
                
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(component,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    
    formHeader : function(component, event, helper) {
        
        var tableHeader = [
            {
                'label': 'Modified DateTime',
                'name' : 'dateAndTime',
                'type' : 'String'
            },
            {
                'label': 'By User',
                'name' : 'byUser',
                'type' : 'String'
            },
            {
                'label': 'Field Edited',
                'name' : 'fieldEdited',
                'type' : 'String'
            },
            {
                'label': 'Old Value',
                'name' : 'oldValue',
                'type' : 'String'
            },
            {
                'label': 'New Value',
                'name' : 'newValue',
                'type' : 'String'
            },
            {
                'label': 'Contact Name',
                'name' : 'contactName',
                'type' : 'String'
            },
            {
                'label': 'Project',
                'name' : 'project',
                'type' : 'String'
            },
            {
                'label': 'Project Task',
                'name' : 'projectTask',
                'type' : 'String'
            },
            {
                'label': 'Time Card Line',
                'name' : 'tclName',
                'type' : 'String'
            }
        ];
        component.set("v.tabelHeader", tableHeader);
    },
    
    getRecsToDownload : function(component, event, helper) {
        
        var filterObj = component.get("v.filterObj");
        
        var fromDate = filterObj.fromDateVal || null;
        var toDate = filterObj.toDateVal || null;
        var insName = '';
        var userName = '';
        var projName = '';
        
        if(filterObj && filterObj.selectedConName && filterObj.selectedConName.length > 0 && filterObj.selectedConName[0].Name){
            insName = filterObj.selectedConName[0].Name;
        }
        if(filterObj && filterObj.selectedUser && filterObj.selectedUser.length > 0 && filterObj.selectedUser[0].Name){
            userName = filterObj.selectedUser[0].Name;
        }
        if(filterObj && filterObj.selectedProjName && filterObj.selectedProjName.length > 0 && filterObj.selectedProjName[0].Name){
            projName = filterObj.selectedProjName[0].Name;
        }
        
        var param = {};
        param.fromDate = fromDate;
        param.toDate = toDate;
        param.insName = insName;
        param.userName = userName;
        param.projName = projName;
        
        var self = this;
        const server = component.find('server');
        const action = component.get('c.getAuditReportRecsToDownload');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) {
                
                var result = response;
                component.set("v.tcdHistoryRecsToDownload", result);
                var rows = component.get("v.tcdHistoryRecsToDownload");
                if(rows.length > 0){
                    var columns = component.get("v.tabelHeader");
                    var fileName = 'Audit Trail Report';
                    helper.exportAsFileType(component,columns,rows,fileName,'csv',false); 
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(component,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    
    exportAsFileType : function(component,columns,rows,fileName,type,useValuePropForReference) {
        var self = this;
        // This builds the spreadsheet - the headerColumns are the first row
        // and the spreadsheet data is an array of arrays for the rest of the data
        this.setData = function(headerColumns, spreadsheetData) {
            // Gets the labels from the data columns 
            
            var columnNames = [];
            
            headerColumns.forEach(function(thisHeaderRow) {
                // Add the name if there's no label for some reason 
                
                var columnId = thisHeaderRow["label"] || thisHeaderRow["name"];
                columnNames.push(columnId);
            });
                        
            var rows = [columnNames];                 
            // Iterate through every line item
            spreadsheetData.forEach(function(thisRecord) {
                var thisRecordProperties = [];
                // For each header column, get the property on the record that matches the name of the column
                headerColumns.forEach(function(thisRow) {
                    if(thisRecord[thisRow["name"]]){
                        thisRecordProperties.push(('"'+thisRecord[thisRow["name"]]).replace('/[#]/g','')+'"');  
                    }else{
                        thisRecordProperties.push(thisRecord[thisRow["name"]]);  
                    } 
                });
                
                // Push all the properties extracted from this line item to the data rows array
                rows.push(thisRecordProperties);
            });
            this.rows = rows;
        };
        
        this.setData(columns, rows); // Call setData on object construction
        // This function actually downloads the spreadsheet
        this.downloadData = function() {
            var isInIE = this.getIsIE();
            
            var fileContent = (!isInIE) ? "data:text/plain;charset=utf-8," : "";
            
            // Right now rows is an array of arrays, break each inner array into a tab-separated string
            this.rows.forEach(function(rowArray) {
                console.log(rowArray);
                var row = rowArray.join(",");
                console.log('join',row);
                fileContent += row + "\r\n"; // Add carriage return
            }); 
            
            // Create an anchor element with the fileContent, this will allow us to automatically download file
            var encodedUri = encodeURI(fileContent);
            
            var link = document.createElement("a");
            let blob = new Blob([fileContent]);
            
            if(isInIE && !window.navigator.msSaveOrOpenBlob) {
                link.href = window.URL.createObjectURL(blob, {type: "text/plain"});
                link.download = this.getFileName();
            } else {
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", this.getFileName());
            }
            
            
            if(!isInIE) {
                link.click();
            } else {
                
                if (window.navigator.msSaveOrOpenBlob) {
                    window.navigator.msSaveBlob(blob, this.getFileName());
                }
                else {
                    link.click(); 
                }
            }
        };
        
        // Getter and Setter for the file name
        this.setFileName = function(fileName,type) {
            // Add a file extension if one wasn't passed in
            
            if(fileName && type){
                fileName += '.' + type;
            }
            
            this.fileName = fileName;
        };
        this.setFileName(fileName,type);
        
        this.getFileName = function() {
            if(this.fileName) {
                return this.fileName;
            } else {
                if(type) return "Unnamed_Document." + type;
                return "Unnamed_Document.csv";
            }
        };	
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE");
        
        // Returns true if the browswer is IE or Edge; otherwise false
        this.getIsIE = function() {
            // Checks for instance of documentMode (IE-only property) or the userAgent with name of "Edge"
            if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./) || /Edge/.test(navigator.userAgent)) {
                return true;
            } else {
                return false;
            }
        }
        this.downloadData();
    },
    
    showToast : function(component,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
})