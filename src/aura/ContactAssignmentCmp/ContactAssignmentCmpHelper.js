({
    assignTable: function(cmp, event) { 
        
        var tabName = cmp.get("v.activeTab");
        var header = [];
        var objName = cmp.get("v.sObjectName");
        var isDisplayAction = cmp.get("v.isDisplayAction");
        
        if (tabName == 'Student') {
            var stuPositionRecTypes = ['DODA_Projects','DLI_W_LT_Projects','Language_Training_Projects','ESL_LT_Projects'];

            header = [{
                'label':'Contact	',
                'name':'Candidate_Name__r.Name',
                'type':'reference',
                'value':'Candidate_Name__c', 
                'truncate': {
                    "characterLength": 10,
                },
                'width':'13%',
                'sortable':false,
                'target':'_blank',
            }, {
                'label':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'ORAL EXAM DATE & TIME': 'Start Date ',
                'name':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'Oral_Exam_Date_Time__c': 'Start_Date__c',
                'type':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'text': 'date',
                'format':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? '': 'MM/DD/YYYY',
                'sortable':false,
                "width":"12%",
            }, {
                'label':'End Date	',
                'name':'End_Date__c',
                'type':'date',
                'format':'MM/DD/YYYY',
                'sortable':false,
                "width":"10%",
                
            },{
                'label':'POSITION	',
                'name':'Assignment_Position__c',
                'type':'text',
                'sortable':false,
                'visible': stuPositionRecTypes.includes(cmp.get("v.parentRecordType"))
                
            },{
                'label':'Email	',
                'name':'Email__c',
                'type':'Email',
                'sortable':false,
                "width":"12%",
                'truncate': {
                    "characterLength": 18,
                }
                
            }, {
                'label':'Mobile	',
                'name':'Mobile__c',
                'type':'Phone',
                'sortable':false,
                "width":"10%",
                'truncate': {
                    "characterLength": 10,
                }
            }, {
                'label':'Status	',
                'name':'Status__c',
                'type':'text',
                'sortable':false,
                "width": "10%",
                'truncate': {
                    "characterLength": 12,
                }
                
            }];
        }
        if (tabName == 'Client/Partner' || tabName == 'Consultant') {
            //  console.log('tab name is ' + tabName);
            header.push({
                'label':'Contact',
                'name':'Candidate_Name__r.Name',
                'type':'reference',
                'value':'Candidate_Name__c',
                'sortable':false,
                'target':'_blank',
                'truncate': {
                    "characterLength": 10,
                },
            }, {
                'label':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'ORAL EXAM DATE & TIME': 'Start Date ',
                'name':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'Oral_Exam_Date_Time__c': 'Start_Date__c',
                'type':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'text': 'date',
                'format':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? '': 'MM/DD/YYYY',
                'width':'12%',
                'sortable': false,
            }, {
                'label':'End Date	',
                'name':'End_Date__c',
                'type':'date',
                'sortable':false,
                'format':'MM/DD/YYYY',
            }, {
                'label':'Email	',
                'name':'Email__c',
                'type':'Email',
                'sortable':false,
                'width':'13%',
                'truncate': {
                    "characterLength": 14,
                },
            }, {
                'label':'Mobile	',
                'name':'Mobile__c',
                'type':'Phone',
                'sortable': false,
                
            }, {
                'label':'POSITION	',
                'name':'Assignment_Position__c',
                'type':'text',
                'sortable':false,
            }, {
                'label':'Status	',
                'name':'Status__c',
                'type':'text',
                'sortable':false,
                
            });
        }
        if (tabName == 'Instructor' || tabName == 'Direct Labor') {
            header.push({
                'label':'SEQ #	',
                'name':'Sequence__c',
                'type':'number',
                'sortable':false,
                'width':'60px',
                'truncate':{
                    "characterLength" :3
                }
            }, {
                'label':'Contact	',
                'name':'Candidate_Name__r.Name',
                'type':'reference',
                'value':'Candidate_Name__c',
                'sortable':false,
                'target':'_blank',
                'width':'10%',
                'truncate': {
                    "characterLength": 10,
                }
            });
            if (objName == 'Opportunity') {
                header.push({
                    'label': 'OPPORTUNITY PRODUCT',
                    'name': 'oppProducName',
                    'type': 'reference',
                    'value': 'Opportunity_Product_Id__c',
                    'sortable': false,
                    'target': '_blank',
                    'truncate': {
                        "characterLength": 10,
                    },
                    'width': '13%',
                });
            } else if (objName == 'AcctSeed__Project__c') {
                header.push({
                    'label': 'PROJECT TASK',
                    'name': 'Project_Task__r.Name',
                    'type': 'reference',
                    'value': 'Project_Task__c',
                    'sortable': false,
                    'target': '_blank',
                    'truncate': {
                        "characterLength": 10,
                    },
                    'width': '12%'
                });
            }
            header.push({
                'label':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'ORAL EXAM DATE & TIME': 'Start Date ',
                'name':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'Oral_Exam_Date_Time__c': 'Start_Date__c',
                'type':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'text': 'date',
                'format': (cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? '': 'MM/DD/YYYY',
                'width' :'12%',
                "sortable": false,
            }, {
                'label': 'End Date	',
                'name': 'End_Date__c',
                'type': 'date',
                'format': 'MM/DD/YYYY',
                "sortable": false,
            }, {
                'label': 'POSITION	',
                'name': 'Assignment_Position__c',
                'type': 'text',
                "sortable": false,
                'width': '9%',
            });
            if(cmp.get("v.parentRecordType") == 'Translation_Opportunities' || cmp.get("v.parentRecordType") == 'Translation_Projects'){
                header.push({
                    'label': 'Total Qty Planned',
                    'name': 'Total_Qty_Planned__c',
                    'type': 'text',
                    "sortable": false,
                    'width': '11%',
                });
            }
            header.push({
                'label': 'COST RATE',
                'name': 'CostRateNAME',
                'type': 'reference',
                'value': 'CrID',
                "sortable": false,
                'class':'linkstyle',
                'target': '_blank',
                'truncate': {
                    "characterLength": 10,
                },
                
            }, {
                'label': 'Status	',
                'name': 'Status__c',
                'type': 'text',
                "sortable": false,
                'width': '9%',
                
            });
        }
        if (tabName == 'Supervisor/LTS' || tabName == 'Overhead' || tabName == 'Staff' || tabName == 'DLS Staff') {
            header.push({
                'label': 'Contact	',
                'name': 'Candidate_Name__r.Name',
                'type': 'reference',
                'value': 'Candidate_Name__c',
                'target': '_blank',
                'sortable': false,
                'width':'13%',
                'truncate': {
                    "characterLength": 10,
                },
            });
            if (objName == 'Opportunity') {
                header.push({
                    'label': 'OPPORTUNITY PRODUCT',
                    'name': 'oppProducName',
                    'type': 'reference',
                    'value': 'Opportunity_Product_Id__c',
                    'target': '_blank',
                    'sortable': false,
                    'width':'13%',
                    'truncate': {
                        "characterLength": 15,
                    },
                    
                });
            } else if (objName == 'AcctSeed__Project__c' || objName =='Contract' ) {
                header.push({
                    'label': 'PROJECT TASK',
                    'name': 'Project_Task__r.Name',
                    'type': 'reference',
                    'value': 'Project_Task__c',
                    'target': '_blank',
                    'sortable': false,
                    'truncate': {
                        "characterLength": 9,
                    },
                });
            }
            header.push({
                'label':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'ORAL EXAM DATE & TIME': 'Start Date ',
                'name':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'Oral_Exam_Date_Time__c': 'Start_Date__c',
                'type':(cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? 'text': 'date',
                'format': (cmp.get("v.parentRecordType") == 'Testing_Opportunities' || cmp.get("v.parentRecordType") == 'Testing_Projects') ? '': 'MM/DD/YYYY',     
                'width' :'12%',
                "sortable": false,
                'width':'10%',
            }, {
                'label': 'End Date',
                'name': 'End_Date__c',
                'type': 'date',
                'format':'MM/DD/YYYY',
                "sortable": false,
                'width':'10%',
                
            }, {
                'label': 'POSITION',
                'name': 'Assignment_Position__c',
                'type': 'text',
                "sortable": false,
                'width':'10%',
                
            },{
                'label': 'COST RATE',
                'name': 'CostRateNAME',
                'type': 'reference',
                'value': 'CrID',
                "sortable": false,
                'style':'linkstyle',
                'width':'8%',
                'target': '_blank',
                'truncate': {
                    "characterLength": 10,
                },
                
            }, {
                'label': 'Status  ',
                'name': 'Status__c',
                'type': 'text',
                "sortable": false,
                'width':'8%',
                'truncate': {
                    "characterLength": 10,
                }
                
            });
        }
        if (objName == 'AcctSeed__Project__c' || isDisplayAction ||objName == 'Contract') {
            
            cmp.set("v.isDisplayLink", true);
            if (tabName == 'Student') {
                var tableConfig = {
                    searchBox: false,
                    searchByColumn: false,
                    paginate: false,
                    sortable: false,
                    "rowAction": [{
                        "type": "image",
                        "class": "imgAction2",
                        "id": "detailstask",
                        "src": "/resource/1482987503000/Detail_Icon",
                    },{
                        "type": "image",
                        "class": "imgAction2",
                        "id": "edittask",
                        "src": "/resource/1482987504000/Edit_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "deltask",
                        "src": "/resource/1482987503000/Delete_Icon",
                    }, {
                        "type": "image",
                        "class": "pdoImgAction",
                        "id": "package",
                        "src": "/resource/1473141301000/PlannedDaysOff_PackageIcon",
                    },/*{
                        "type": "image",
                        "class": "studentTimeLineImgAction",
                        "id": "studentTimeLine",
                        "src": "/resource/1602067711000/Student_TimeLine_Icon",
                    },*/{
                        "type": "image",
                        "class": "goalImgAction",
                        "id": "languageTestingId",
                        "src": "/resource/1602070979000/Goal_Icon",
                    },
                    {
                        "label": "More",
                        "type": "menu",
                        "id": "actions",
                        "menuOptions": [{
                            "label": "View Record",
                            "id": "viewRecord"
                        },
                         {
                            "label": "Transfer",
                            "id": "transfer",
                            "visible":function(task){
                             return  (objName == 'AcctSeed__Project__c' && (task['Status__c'] == 'Active' || task['Status__c'] == 'Planned'));
                         }
                        } ]
                    }
                    ],
                    "rowActionPosition": 'right',
                    "rowClass":"rowClass"
                }
                }
            if (tabName == 'Instructor' || tabName == 'Direct Labor') {
                var tableConfig = {
                    searchBox: false,
                    searchByColumn: false,
                    paginate: false,
                    sortable: false,
                    "rowAction": [{
                        "type": "image",
                        "class": "imgAction2",
                        "id": "detailstask",
                        "src": "/resource/1482987503000/Detail_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "edittask",
                        "src": "/resource/1482987504000/Edit_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "deltask",
                        "src": "/resource/1482987503000/Delete_Icon",
                    }, {
                        "type": "image",
                        "class": "pdoImgAction",
                        "id": "package",
                        "src": "/resource/1473141301000/PlannedDaysOff_PackageIcon",
                    }, {
                        "label": "More",
                        "type": "menu",
                        "id": "actions",
                        "menuOptions": [{
                            "label": "View Record",
                            "id": "viewRecord"
                        } ,{
                            "label": "Gen Tester Payment Form",
                            "id": "genTesterPaymentForm",
                            "visible":function(task){
                                return (objName != 'Opportunity' && cmp.get("v.defaultCostRate") == 'Non-SCA Testing');
                            }
                        }, {
                            "label": "Gen & Send Tester Payment Form",
                            "id": "genSendTesterPaymentForm",
                            "visible":function(task){
                                return (objName != 'Opportunity' && cmp.get("v.defaultCostRate") == 'Non-SCA Testing');
                            }   
                        },{
                            "label": "Pay Rate Modification",
                            "id": "payRateModification",
                            "visible":function(task){
                                return (objName == 'AcctSeed__Project__c' && task['CrID'] != null  && task['Status__c'] != 'Ended' && (cmp.get("v.contactAssignCRChildCountMap") && (cmp.get("v.contactAssignCRChildCountMap")[task['Candidate_Name__c']+'-'+task['CrID']]) == 0) && task['CRStatus'] != 'Inactive');
                            } 
                        },{
                            "label": "Additional Compensation",
                            "id":"additionalCompensation",
                            "visible":function(task){
                             return (task['Status__c'] == 'Active' || task['Status__c'] == 'Planned');
                            }
                        }]
                    }],
                    "rowActionPosition": 'right',
                    "rowClass": 'rowClass'
                };
            }
            if (tabName == 'Supervisor/LTS' || tabName == 'Overhead' || tabName == 'Staff' || tabName == 'DLS Staff') {
                
                var tableConfig = {
                    searchBox: false,
                    searchByColumn: false,
                    paginate: false,
                    sortable: false,
                    "rowAction": [{
                        "type": "image",
                        "class": "imgAction2",
                        "id": "detailstask",
                        "src": "/resource/1482987503000/Detail_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "edittask",
                        "src": "/resource/1482987504000/Edit_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "deltask",
                        "src": "/resource/1482987503000/Delete_Icon",
                    }, 
                                  {
                                      "label": "More",
                                      "type": "menu",
                                      "id": "actions",
                                      "menuOptions": [{
                                          "label": "View Record",
                                          "id": "viewRecord"
                                      } ,{
                                          "label": "GEN OFFER LETTER",
                                          "id": "genOffer"
                                      }]
                                      
                                  }],
                    "rowActionPosition": 'right',
                    "rowClass":"rowClass"
                };
            }
            if (tabName == 'Client/Partner' || tabName == 'Consultant') {
                var tableConfig = {
                    searchBox: false,
                    searchByColumn: false,
                    paginate: false,
                    sortable: false,
                    "rowAction": [{
                        "type": "image",
                        "class": "imgAction2",
                        "id": "edittask",
                        "src": "/resource/1482987504000/Edit_Icon",
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "deltask",
                        "src": "/resource/1482987503000/Delete_Icon",
                    }],
                    "rowActionPosition": 'right',
                    "rowClass":"rowClass"
                };
            }
        } else {
            var tableConfig = {
                searchBox: false,
                searchByColumn: false,
                paginate: false,
                sortable: false
            };
        }
        cmp.set("v.header", header);
        cmp.set("v.config", tableConfig);
        cmp.set("v.showSpinner", false);
        cmp.set("v.displayTable", true);
    },
    RateCardRateOPPt : function(component,helper,event){
        var  conAssign = component.get("v.contactAssignRecs");
        
        for(var i = 0;i < conAssign.length;i++){
            if(component.get("v.sObjectName") == 'Opportunity' ){
                if(conAssign[i].Opportunity_Product_Id__c != null){
                    conAssign[i]['oppProducName'] = component.get("v.opportunitylineItems")[conAssign[i].Opportunity_Product_Id__c];
                }
            }
            if(conAssign[i].Drafted_Labor_Cost_Rate__c != null){
                if(conAssign[i].Drafted_Labor_Cost_Rate__r.Status__c != 'Approved'){
                    conAssign[i]['CostRateNAME'] = conAssign[i].Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c+' ('+conAssign[i].Drafted_Labor_Cost_Rate__r.Status__c+')';
                }else {
                    conAssign[i]['CostRateNAME'] = conAssign[i].Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c;
                }
                conAssign[i]['CrID'] = conAssign[i].Drafted_Labor_Cost_Rate__c;
                conAssign[i]['CRStatus'] = conAssign[i].Drafted_Labor_Cost_Rate__r.Status__c;
                conAssign[i]['CRRateType'] = conAssign[i].Drafted_Labor_Cost_Rate__r.Rate_Type__c;
                
                
            }else if(conAssign[i].Rate_Card_Rate__c != null){
                if(conAssign[i].Rate_Card_Rate__r.Status__c != 'Approved'){
                    conAssign[i]['CostRateNAME'] = conAssign[i].Rate_Card_Rate__r.Cost_Rate_Name__c+' ('+conAssign[i].Rate_Card_Rate__r.Status__c+')';
                }else {
                    conAssign[i]['CostRateNAME'] = conAssign[i].Rate_Card_Rate__r.Cost_Rate_Name__c;
                }
                conAssign[i]['CrID'] = conAssign[i].Rate_Card_Rate__c;
                conAssign[i]['CRStatus'] = conAssign[i].Rate_Card_Rate__r.Status__c;
                conAssign[i]['CRRateType'] = conAssign[i].Rate_Card_Rate__r.Rate_Type__c;
            }
        }
        component.set("v.contactAssignRecs", conAssign);
    }
})