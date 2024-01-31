({
    getListViewValues: function(cmp,event) {
        cmp.set("v.showSpinner",true);
        var self = this;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getListViewOptions');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);    
                var result = JSON.parse(response);
                console.log('::::::::result:::',result);
                cmp.set("v.listViewOptions",result);
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
            }),
            false, 
            false,
            false
        );
    },
    getSobjectRecords : function(cmp, event){
        cmp.set("v.showSpinner",true);
        var self = this;
        var param = {};
        param.queryId = cmp.get("v.selectedListView");
        
        const server = cmp.find('server');
        const action = cmp.get('c.getListViewRecords');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);    
                var result = response;
                console.log(':::::column:::',result.columnJson);
                var column = result.columnJson;
                console.log(JSON.parse(column));
                self.exportRecords(cmp,result.contactRecords,JSON.parse(column),result.fieldTypeMap);
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errors[0].message,
                    "type":"error",
                    "mode": 'sticky',
                });
                toastEvent.fire();
            }),
            false, 
            false,
            false
        );
    },
    exportRecords :  function(cmp,data,columns,fieldTypeMap){
        console.log('::::::::::data::::',data.length);
        console.log('::::::::::columns::::',columns);
        //console.log('::::::constructed string::::',this.generateCSV(data, columns,fieldTypeMap));
        this.downloadCSV(this.generateCSV(data, columns,fieldTypeMap),'Contact Records');
    },
    generateCSV :  function(arrayOfData, tableHeader, fieldTypeMap) {
        var csvContent = "";
        for(var i = 0; i < tableHeader.length; i++) {
            csvContent += tableHeader[i].label;
            if(i != tableHeader.length - 1){
                csvContent += ',';
            }
        }
        csvContent += '\n';
        for(var i = 0; i < arrayOfData.length; i++) {
            for(var j = 0; j < tableHeader.length; j++) {
                var skey = tableHeader[j].value;
                if(skey.includes(".")) {
                    let skeySet = skey.split('.');
                    var objRec = arrayOfData[i];
                    skeySet.forEach(function(key) {
                        if(objRec) {
                            objRec = objRec[key];
                        }
                    });
                    if(objRec){
                        //console.log('Parent field::::',fieldTypeMap[skey])
                        if(fieldTypeMap[skey] == 'Date' || fieldTypeMap[skey] == 'DateTime'){
                            let fieldDate = new Date(objRec);
                            csvContent += this.constructDate(objRec);
                            if(fieldTypeMap[skey] == 'DateTime') {
                                csvContent += this.constructDateTime(fieldDate);
                            }
                        }else{
                            csvContent += objRec; 
                        }
                    }else{
                        csvContent += ''; 
                    }
                    
                }else{
                    if(arrayOfData[i][skey]) {
                        
                        //console.log('Data:::',arrayOfData[i][skey]);
                        //console.log('type of data:::',skey);
                        //console.log('fieldTypeMap:::::',fieldTypeMap[skey]);
                        if(fieldTypeMap[skey] == 'Date' || fieldTypeMap[skey] == 'DateTime') {
                            let fieldDate = new Date(arrayOfData[i][skey]);
                            csvContent += this.constructDate(arrayOfData[i][skey]);
                            
                            if(fieldTypeMap[skey] == 'DateTime') {
                                csvContent += this.constructDateTime(fieldDate);
                            }
                        }else if(fieldTypeMap[skey] == 'string'){
                            csvContent += '"' + arrayOfData[i][skey].split('"').join('""') +'"'; 
                        }else {
                            csvContent += arrayOfData[i][skey]; 
                        }
                    }else{
                        csvContent += '';
                    }
                    
                }
                
                csvContent += ',';
            }
            if(i != arrayOfData.length - 1){
                csvContent += '\n';
            }
        }
        return csvContent;
    },
    downloadCSV : function(csvContent, filename){
        console.log(':::::::enter:::downloadcsv',filename,csvContent.length);
        /*var encodedData = encodeURI(csvContent);
        var link = document.createElement("a");
        link.setAttribute('href', encodedData);
        link.setAttribute('download', filename + '.csv');
        link.click();*/
        var csvData = new Blob([csvContent], { type: 'text/plain' }); 
        var csvUrl = URL.createObjectURL(csvData);
        var link = document.createElement("a");
        link.setAttribute('href', csvUrl);
        link.setAttribute('download', filename + '.csv');
        link.click();
    },
    
    constructDate : function(fieldDate){
        /* fieldDate.setTime(fieldDate.getTime() + fieldDate.getTimezoneOffset()*60*1000);
        var day = fieldDate.getDate();
        var month = fieldDate.getMonth();
        if(month < 10)
            month = '0'+month;
        if(day < 10)
            day = '0'+day
            
        return month+'/'+day+'/'+fieldDate.getFullYear();*/
        
        let fieldDate1 = fieldDate.split('T')[0];
        let dateArray = fieldDate1.split('-');
        return dateArray[1]+'/'+dateArray[2]+'/'+dateArray[0];
    },
    
    constructDateTime : function(fieldDate){
        let hr = fieldDate.getHours();
        let min = fieldDate.getMinutes();
        let sec = fieldDate.getSeconds();
        if(hr < 10)
            hr = '0'+hr;
        if(min < 10)
            min = '0'+min;
        if(sec < 10)
            sec = '0'+sec;
        
        return ' '+hr+':'+min+':'+sec;
    }
})