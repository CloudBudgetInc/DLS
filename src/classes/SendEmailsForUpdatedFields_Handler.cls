/*
* Developed by Karthiga on April 10, 2017
* Class to send email for the changes that's been done in a record
*/

public Class SendEmailsForUpdatedFields_Handler {
    
    /*
    * Checks for the change in Record based on each and every field and sends mail
    * @objName - API name of the Sobject (eg: Contact, Custom_Object__c,..)
    * @newList - trigger.new value from the trigger (List of Sobject)
    * @oldMap - trigger.oldMap value from the trigger (Map of Id and Sobject)
    * @sendEmailTo - Name of the Custom Setting name from "System Value" Custom Setting
    */
    
    public static Set<Id> subSchIdSet = new Set<Id>(); // to store the Schedule Id of Substitute type
    public static Map<Id, Schedule__c> parentSchIdRecMap = new Map<Id, Schedule__c>(); // to store the old records (prior schedule or trigger.oldMap)
    public static commonWrapper wrapSch = new commonWrapper();
    public static Map<Id, Schedule__c> roomChangeSchMap = new Map<Id, Schedule__c>(); // to store the Schedule Id and record of room change type
    public static Map<Id,String> extendedSchIdWithMailContentMap = new Map<Id,String>(); // to store the object Id and its mail content
    public static Map<Id,String> extendedSchIdSubjectMap = new Map<Id,String>(); // to store the object Id and subject of mail for extended type 
    Map<Id,AcctSeed__Project__c> projIdRecMap = new Map<Id,AcctSeed__Project__c>(); // to store the project Id and record - used in the reference field
    Map<Id,User> userMap = new Map<Id,User>(); // to store the user Id and record - used in the reference field
    
    public void sendEmail(String objName, List<Sobject> newList, Map<Id,sobject> oldMap, String sendEmailTo) {
       
        List<Messaging.SingleEmailMessage> mailSend = new List<Messaging.SingleEmailMessage>();
        idSetObjFieldWrapper idObjFieldWrap = new idSetObjFieldWrapper();
        
        idObjFieldWrap = getObjIdRecord(newList, oldMap, objName, 'Update', idObjFieldWrap);
        commonWrapper wrap = getRecord(idObjFieldWrap);
        
        Map<Id, String> subjectMap = new Map<Id, String>();
        Map<Id,String> idWithMailBodyMap = new Map<Id,String>();
        Map<Id,Sobject> ObjIdAndRecordMap = wrap.ObjIdAndRecordMap;
        Map<String, Schema.SObjectField> fieldMap = wrap.fieldMap;
        String objectLabel = wrap.objectLabel; 
        Map<Id,Contract> conrtIdRecMap = wrap.conrtMap;
        userMap = wrap.usersMap;
        
        for (Sobject o : newList) {
        
        Boolean addSch = false;
       
            Id oldMapId = o.Id;
            Id modifiedBy = String.ValueOf(o.get('LastModifiedById'));
            String emailBody = '<html><p>The following Values are modified in the '+ objectLabel +' by '+ getValueFromMap(userMap, modifiedBy, 'Name') +'<br/>';
            String tableStr = '';
            
            if(objName != 'Contract') 
                subjectMap.put(o.Id, objectLabel +' Modified for: '+getValueFromMap(oldMap, o.Id, 'Name'));
            
            if(objName == 'Contract_Modification__c') {
                emailBody += '<br/>Contract Name: '+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract_Number__c'), 'Name');
                emailBody += '<br/><br/>Contract No: '+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract_Number__c'), 'Contract_No__c');
                emailBody += '<br/><br/>Contract Value(Total Funded): $ '+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract_Number__c'), 'Total_Contract_Value_Options__c') +'</p>';
            } else if (objName == 'Contract') {
                subjectMap.put(o.Id, objectLabel +' Modified for: '+(o.get('Name') == null ? '' : o.get('Name')));
                emailBody += '<br/>Contract Name: '+ (o.get('Name') == null ? '' : o.get('Name'));
                emailBody += '<br/><br/>Contract No: '+ (o.get('Contract_No__c') == null ? '' : o.get('Contract_No__c'));
                emailBody += '<br/><br/>Contract Value(Total Funded): $ '+ (o.get('Total_Contract_Value_Options__c') == null ? 0 : o.get('Total_Contract_Value_Options__c'))+'</p>';
            } else if(objName == 'CLIN__c') {
                emailBody += '<br/>Contract Name: '+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract__c'), 'Name');
                emailBody += '<br/><br/>Contract No: '+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract__c'), 'Contract_No__c');
                emailBody += '<br/><br/>Contract Value(Total Funded): $'+ getValueFromMap(conrtIdRecMap, (Id)o.get('Contract__c'), 'Total_Contract_Value_Options__c')+'</p>';
            } else if (objName == 'Schedule__c') {
                emailbody = '<html>';
                subjectMap.put(o.Id, 'A Schedule for '+ String.ValueOf(o.get('Opp_Project_Name__c')) +' has been edited');
                emailBody += '<p>Hello FEO Team,<br/><br/>';
                emailBody += 'The following field(s) on a schedule for <a href="'+ String.ValueOf(o.get('Opp_Project_Link__c')) +'">'+ String.ValueOf(o.get('Opp_Project_Name__c')) +'</a> have been modified by ' + getValueFromMap(userMap, modifiedBy, 'Name') + '<br/>';
                emailBody += '<br/>Schedule Name: <a href="'+ System.Label.Org_Prefix_Start_URL + '/' + String.ValueOf(o.get('Id')) +'">' + String.ValueOf(o.get('Name'))+'</a></p>';
            }
            tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Label</th><th>Old Value</th><th>New Value</th></thead><tbody>';
            
            idWithMailBodyMap.putAll(formTable(tableStr, fieldMap, emailBody, o, oldMap, oldMapId, '', userMap, ObjIdAndRecordMap, objName));
        }
                
        if(idWithMailBodyMap != null && idWithMailBodyMap.size() > 0) {
            mailSend.addAll(sendMailMethod(idWithMailBodyMap, subjectMap, sendEmailTo));
        }
        
        if( mailSend != null && mailSend.size() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(mailSend);
        }
            
    }
    
    public String ObjectToDateTime(Object o) {
        DateTime dt = DateTime.ValueOf(o);
        String st = dt.format();
        return st;
    }
    
    public String ObjectToDate(Object o) {
        Date dt = Date.ValueOf(o);
        String st = dt.format();
        return st;
    }
    
    public String returnName(Map<Id,SObject> RecMap, Object o) {
        String nme;
        Id rId = (Id)o;
        if(RecMap != null && RecMap.containskey(rId)) {
            Sobject so = RecMap.get(rId);
            nme = (String)so.get('Name');
        }
        return nme;
    }
    
    // Added by E. Keerthika on 21th, August 2018
    
    // To send the mail when the schedule or instructor of the project has been changed
    public void sendMailSchUpdate(Map<String, List<Schedule__c>> schMap, Set<Id> parentIds, Map<Id, Schedule__c> extendedSchOldMap) {
        
        Map<Id,String> objIdMailBodyMap = new Map<Id,String>();
        List<mailWrapper> mailWrap = new List<mailWrapper>();
        List<Messaging.SingleEmailMessage> mailSend = new List<Messaging.SingleEmailMessage>();
        
        if(schMap != null && schMap.size() > 0 && ((parentIds != null && parentIds.size() > 0) || (extendedSchOldMap != null && extendedSchOldMap.size() > 0))) {
            
            // Shedule is updated and new schedule is created when the room is changed, schedule is changed and instructor is replaced or substituted for the schedule
            if(parentIds != null) {
                for(Schedule__c sch : ScheduleService.getScheduleRec(' WHERE Id ', ', Instructor__r.Name, Project__r.Project_Manager__c, Room__r.Name', parentIds)) {
                    parentSchIdRecMap.put(sch.Id, sch);
                }
            } 
            
            // Only for Extended schedule type (Only the schedule is updated and no new schedule is created when the date is extended for schedule)
            if(extendedSchOldMap != null && extendedSchOldMap.size() > 0) {
                parentSchIdRecMap.putAll(extendedSchOldMap);
            }
            
            if(parentSchIdRecMap != null && parentSchIdRecMap.size() > 0) {
                idSetObjFieldWrapper idObjFieldWrap = new idSetObjFieldWrapper();
                for(String schType : schMap.keySet()) {
                    if(schType != 'Extended') {
                        idObjFieldWrap = getObjIdRecord(schMap.get(schType), parentSchIdRecMap, 'Schedule__c', 'Insert', idObjFieldWrap);
                    } else if(schType == 'Extended') {
                        idObjFieldWrap = getObjIdRecord(schMap.get(schType), parentSchIdRecMap, 'Schedule__c', 'Update', idObjFieldWrap);
                    }
                    //mailWrap.add(getSchTable(schMap.get(schType), parentSchIdRecMap, 'Schedule__c', wrap));
                }  
                
                // Only for Substitute Schedule type
                if(schMap.containsKey('Substitute')) {
                    for(Schedule__c sch : schMap.get('Substitute')) {
                        subSchIdSet.add(sch.Id);
                    }
                }

                // To query all the parent record information only once.
                wrapSch = getRecord(idObjFieldWrap);
                
                for(String schType : schMap.keySet()) {
                    if(schType != 'Substitute') {
                        mailWrap.add(getSchTable(schMap.get(schType), parentSchIdRecMap, 'Schedule__c', wrapSch));
                    }     
                } 
               
                if(mailWrap != null && mailWrap.size() > 0) {
                    for(mailWrapper wrp : mailWrap) {
                        mailSend.addAll(sendMailMethod(wrp.idWithMailBodyMap, wrp.subjectMap, 'Schedule Update Notify Mail'));
                    }
                }  

                if(mailSend != null && mailSend.size() > 0 && !Test.isRunningTest()) {
                    Messaging.sendEmail(mailSend);
                }
            }
        }
    }
    
    // Method to Display the Record Name instead of Id Values for reference field
    public idSetObjFieldWrapper getObjIdRecord(List<Sobject> newList, Map<Id, sObject> oldMap, String objName, String action, idSetObjFieldWrapper wrap) {
        
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName});
        Map<String,Set<Id>> ObjectNameAndJointedIdMap = new Map<String,Set<Id>>();
        Map<Id,Sobject> ObjIdAndRecordMap = new Map<Id,Sobject>();
        String objectLabel;
        String Subject = '';
        
        if( describeSobjectsResult != null && describeSobjectsResult.size() > 0 ) {
            
            objectLabel = describeSobjectsResult[0].getLabel();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
            Map<Id,String> idWithMailBodyMap = new Map<Id,String>();
            Map<Id, Contract> conrtIdRecMap = new Map<Id, Contract>();
            Map<Id,AcctSeed__Project_Task__c> proTaskMap = new Map<Id,AcctSeed__Project_Task__c>();
            Map<Id,Room__c> roomMap = new Map<Id,Room__c>();
            Set<Id> userId = new Set<Id>();
            Set<Id> conrtId = new Set<Id>();
            Set<Id> projId = new Set<Id>();
            Set<Id> proTaskId = new Set<Id>();
            Set<Id> roomId = new Set<Id>();

            for (Sobject newRec : newList) {
                
                Id oldMapId = newRec.Id;
                String schType = '';
                
                if(objName == 'Schedule__c') {
                
                    Schedule__c sch = (Schedule__c) newRec;
                    schType = sch.Schedule_Type__c;
                       
                    if(schType != 'Regular' && action == 'Insert')
                        oldMapId = sch.Prior_Schedule__c;
                    
                    // this map used to get the project manager mail address
                    if(schType == 'Room Change') {
                        Schedule__c oldRec = (Schedule__c)oldMap.get(oldMapId);
                        if(sch.Room__c != oldRec.Room__c) {
                            roomChangeSchMap.put(newRec.Id, sch);
                        }
                    }
                }
                
                for(String fn: fieldMap.keyset()) {
                
                    if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Reference') {
                        
                        Id rId = oldMap.containsKey(oldMapId) && (Id)oldMap.get(oldMapId).get(fn) != null ? (Id)getValueFromMap(oldMap, oldMapId, fn) : (Id)newRec.get(fn);
                        if(rId != null) {
                            String obj = rId.getSObjectType().getDescribe().getName();
                            
                            // To capture the modified field values only
                         
                            if(fn != 'systemmodstamp' && newRec.get(fn) != oldMap.get(oldMapId).get(fn) && fieldMap.get(fn).getDescribe().getRelationshipName() != 'LastModifiedBy') {
                                
                                if(!ObjectNameAndJointedIdMap.containskey(obj)) {
                                    ObjectNameAndJointedIdMap.put(obj,new Set<Id>{(ID)newRec.get(fn),rId});
                                } else {
                                    ObjectNameAndJointedIdMap.get(obj).addAll(new Set<Id>{(ID)newRec.get(fn),rId});
                                }
                            }
 
                            // To capture the field values need for email body construction other than table
                            
                            if(obj == 'User') {
                                userId.add((ID)newRec.get(fn));
                                if(getValueFromMap(oldMap, oldMapId, fn) != '') // To fix the issues for Contract Activation (Since the oldMap doesn't have the activatedById)
                                    wrap.userIdSet.add((ID)getValueFromMap(oldMap, oldMapId, fn));
                            }
                                
                            if(obj == 'Contract' && (objName == 'Contract_Modification__c' || objName == 'CLIN__c')) {
                                wrap.contractIdSet.add((ID)newRec.get(fn));
                            }
                            
                            if(obj == 'AcctSeed__Project__c') {
                                wrap.projectIdSet.add((ID)newRec.get(fn));
                            }
                            
                            if(obj == 'AcctSeed__Project_Task__c') {
                                wrap.projectTaskIdSet.add((ID)newRec.get(fn));
                            }
                            
                            if(obj == 'Room__c') {
                                wrap.roomIdSet.add((ID)newRec.get(fn));
                            }
                        
                        }
                    } 
                }
            }
            
            wrap.fieldMap = fieldMap;
            wrap.objectLabel = objectLabel;
            wrap.ObjectNameAndJointedIdMap = ObjectNameAndJointedIdMap;
        }
        return wrap;
    }
    
    public commonWrapper getRecord(idSetObjFieldWrapper idObjFieldWrap) {
        
        commonWrapper wrap = new commonWrapper();        
        
        if(idObjFieldWrap.contractIdSet != null && idObjFieldWrap.contractIdSet.size() > 0) {
            wrap.conrtMap = new Map<Id, Contract>([SELECT Id,Name,Contract_No__c,Total_Contract_Value_Options__c FROM Contract WHERE Id IN :idObjFieldWrap.contractIdSet]);
        }
        
        if(idObjFieldWrap.projectIdSet != null && idObjFieldWrap.projectIdSet.size() > 0) {
            wrap.projMap = new Map<Id,AcctSeed__Project__c>([SELECT Id,Name, Project_Manager__c FROM AcctSeed__Project__c WHERE ID IN: idObjFieldWrap.projectIdSet]);
            
            for(Id proId : wrap.projMap.keySet()) {
                if(wrap.projMap.get(proId).Project_Manager__c != null)
                    idObjFieldWrap.userIdSet.add(wrap.projMap.get(proId).Project_Manager__c);
            }
        }
        
        if(idObjFieldWrap.projectTaskIdSet != null && idObjFieldWrap.projectTaskIdSet.size() > 0) {
            wrap.proTaskMap = new Map<Id,AcctSeed__Project_Task__c>([SELECT Id,Name FROM AcctSeed__Project_Task__c WHERE ID IN: idObjFieldWrap.projectTaskIdSet]);
        }
        
        if(idObjFieldWrap.roomIdSet != null && idObjFieldWrap.roomIdSet.size() > 0) {
            wrap.roomMap = new Map<Id,Room__c>([SELECT Id,Name FROM Room__c WHERE ID IN: idObjFieldWrap.roomIdSet]);
        }
        
        if(idObjFieldWrap.userIdSet != null && idObjFieldWrap.userIdSet.size() > 0 ) {
            for( User usr : (List<User>) SObjectQueryService.SObjectQuery('User', idObjFieldWrap.userIdSet ,'')) {
                wrap.usersMap.put(usr.Id,usr);
            }
        }
        
        // To query all the reference that is parent records for the Name display in the Table.
        if(idObjFieldWrap.ObjectNameAndJointedIdMap.size() > 0) {
        
            for(String objnam : idObjFieldWrap.ObjectNameAndJointedIdMap.keyset()) {
            
                Set<Id> tempIdSet = idObjFieldWrap.ObjectNameAndJointedIdMap.get(objnam);
                String multiplequerystr = 'SELECT Id,Name FROM ';
                multiplequerystr += objnam + ' WHERE Id IN :tempIdSet';
               
                for(sObject sobj : Database.query(multiplequerystr)){
                    wrap.ObjIdAndRecordMap.put(String.valueOf(sobj.get('Id')),sobj);
                }
            }                
        } 
        
        wrap.fieldMap = idObjFieldWrap.fieldMap;
        wrap.objectLabel = idObjFieldWrap.objectLabel;
        return wrap;
    }
    
    // Method to form the mail content
    public mailWrapper getSchTable(List<Sobject> newList, Map<Id, Sobject> oldMap, String objType, commonWrapper wrap) {
        
        Map<Id,Sobject> ObjIdAndRecordMap = wrap.ObjIdAndRecordMap;
        Map<String, Schema.SObjectField> fieldMap = wrap.fieldMap;
        Map<Id, Contract> conrtIdRecMap = wrap.conrtMap;
        Map<Id, AcctSeed__Project_Task__c>  proTaskIdRecMap = wrap.proTaskMap;
        Map<Id, Room__c> roomIdRecMap = wrap.roomMap;
        projIdRecMap = wrap.projMap;
        userMap = wrap.usersMap;
        
        Set<String> modifiedFldSet = new Set<String>();
        Map<Id,String> idWithMailBodyMap = new Map<Id,String>();
        mailWrapper mailWrap = new mailWrapper();
        Map<Id, String> schIdSubjectMap = new Map<Id, String>();
        String instructor = '', room = '';
        
        for (Sobject o : newList) {
            
            String emailBody = '<html><p>Hello FEO Team,<br/><br/>';
            String schType = '', tableStr = '';
            Id oldMapId = o.Id;
            
            if(objType == 'Schedule__c' ) {
                Schedule__c sch = (Schedule__c) o;
                schType = sch.Schedule_Type__c;
                if(schType != 'Regular' && schType != 'Extended')
                    oldMapId = sch.Prior_Schedule__c;
              
                Schedule__c schOld = oldMap != null ? (Schedule__c) oldMap.get(oldMapId) : null;
                
                if(schType == 'Replace Instructor' && sch.Instructor__c != null) {
                    
                    instructor = sch.Instructor__c;

                    schIdSubjectMap.put(o.Id, 'An instructor for '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+' has been replaced');
                    
                    emailBody += 'The instructor has been replaced for Schedule:<a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">' + schOld.Name + '</a>'+
                                 ' for ' +getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+' by '+getValueFromMap(userMap, schOld.LastModifiedById, 'Name')+
                                 '. Please see below for details of the new Schedule:<br/><br/>'+getValueFromMap(ObjIdAndRecordMap, sch.Instructor__c, 'Name') + ' will begin on: ' + ObjectToDate(sch.Start_Date__c) + '<br/><br/>The original Schedule record with ' +
                                  schOld.Instructor__r.Name + ' has been updated to end on: '+ ObjectToDate(schOld.End_Date__c)+'. If the end date is in the past, the original schedule Status was also updated to Completed</p>';
                    
                    tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Field Label</th><th>Old Value</th><th>New Value</th></thead><tbody>'+
                                '<tr><td width="25%">Schedule Name</td><td width="25%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">' + 
                                schOld.Name + '</a></td><td width="25%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + sch.Id +'">' + sch.Name + '</a></td></tr>'+
                                '<tr><td width="25%"><b>Instructor Name:</b></td><td width="25%"><b>' + getValueFromMap(ObjIdAndRecordMap, schOld.Instructor__c, 'Name') +'</b></td><td width="25%"><b>'+ 
                                 getValueFromMap(ObjIdAndRecordMap, sch.Instructor__c, 'Name') +'</b></td></tr>';
                    
                } else if(schType == 'Schedule Change') {
                    
                    schIdSubjectMap.put(o.Id, 'A Schedule for '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name') +' has changed');
                    
                    emailBody += 'The following schedule <a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">' + schOld.Name + '</a> for '+getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+
                                  ' has been changed by '+getValueFromMap(userMap, sch.LastModifiedById, 'Name') +'. Please see below for details of the new Schedule:<br/><br/>The new schedule will take effect on: '+
                                  ObjectToDate(sch.Start_Date__c)+'<br/><br/> The old Schedule record has been updated to end on: '+ObjectToDate(schOld.End_Date__c)+'. If the end date is in the past, the original schedule Status was also updated to Completed</p>'; 
                
                     tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Field Label</th><th>Old Value</th><th>New Value</th></thead><tbody>'+
                                 '<tr><td width="25%">Schedule Name</td><td width="25%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">' + 
                                 schOld.Name + '</a></td><td width="25%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + sch.Id +'">' + sch.Name + '</a></td></tr>';
               
                } else if(schType == 'Substitute') {
                   
                    schIdSubjectMap.put(o.Id, 'A Substitute Instructor has been assigned to '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name'));
                    
                    emailBody += 'The following Substitute Instructor has been assigned to '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+
                                 ' by ' + getValueFromMap(userMap,sch.LastModifiedById, 'Name')+'<br/><br/>Schedule Name: <a href="'+ System.Label.Org_Prefix_Start_URL + '/' + 
                                  sch.Id +'">' + sch.Name + '</a><br/><br/><b>SUBSTITUTE INSTRUCTOR: </b>'+(sch.Instructor__c != null ? sch.Instructor__r.Name : '')+'<br/><br/><b>PROJECT TASK: </b>'+getValueFromMap(proTaskIdRecMap,sch.Project_Task__c, 'Name')+
                                  '<br/><br/><b>ROOM: </b>'+getValueFromMap(roomIdRecMap,sch.Room__c, 'Name')+'<br/><br/><b>'/*TOTAL PLANNED QTY: </b>'+''+'</p>*/;
                     
                    //tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Date(s)</th><th>Start Time</th><th>End Time</th><th>Total Hours</th></thead><tbody>';
                    tableStr += emailBody+wrap.schIdTableStrMap.get(o.Id);
               
                } else if(schType == 'Room Change') {
                    
                    room = sch.Room__c;
                    
                    schIdSubjectMap.put(o.Id, 'A room assignment for '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+' has been changed');
                    
                    emailBody = '<html><p>Hello '+getValueFromMap(userMap, getValueFromMap(projIdRecMap, sch.Project__c, 'Project_Manager__c'), 'Name')+',<br/><br/>';
                    emailBody += 'A room has been replaced for Schedule: <a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">'+schOld.Name+'</a> for '+getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+
                                 ' by '+getValueFromMap(userMap, schOld.LastModifiedById, 'Name')+'. Please see below for details of the new Schedule:<br/><br/>'+
                                 'The room will be changed to: '+getValueFromMap(roomIdRecMap,sch.Room__c, 'Name')+' beginning on: '+ObjectToDate(sch.Start_Date__c)+'<br/><br/>The original schedule record with ' +schOld.Name+ 
                                 ' has been marked as completed and updated to end on: '+ObjectToDate(schOld.End_Date__c)+'</p>';
                    tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Field Label</th><th>Old Value</th><th>New Value</th></thead><tbody>'+'<tr><td width="25%">Schedule Name</td><td width="25%">'+
                                '<a href="'+ System.Label.Org_Prefix_Start_URL + '/' + schOld.Id +'">' + schOld.Name + '</a></td><td width="25%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + sch.Id +'">' + sch.Name + '</a></td></tr>'+
                                '<tr><td width="25%"><b>Room Name:</b></td><td width="25%"><b>' + (schOld.Room__c != null ? schOld.Room__r.Name : '') +'</b></td><td width="25%"><b>'+ 
                                getValueFromMap(ObjIdAndRecordMap, sch.Room__c, 'Name') +'</b></td></tr><tr><td width="25%">Last Modified By User</td><td width="25%">' + getValueFromMap(userMap,schOld.LastModifiedById, 'Name')+
                                '</td><td width="25%">'+ getValueFromMap(userMap,sch.LastModifiedById, 'Name')+'</td></tr>';
               
               } else if(schType == 'Extended') {
                   
                   extendedSchIdSubjectMap.put(o.Id, 'The End Date for '+ getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+' has extended');
                   
                   emailBody += 'The End Date for the following schedule <a href="'+ System.Label.Org_Prefix_Start_URL + '/' + sch.Id +'">'+sch.Name+'</a> for '+getValueFromMap(projIdRecMap, sch.Project__c, 'Name')+
                                ' has been extended by '+ getValueFromMap(userMap,sch.LastModifiedById, 'Name')+'.<br/><br/>The updated schedule end date is: '+ObjectToDate(sch.End_Date__c)+'<br/>';
                  
                   tableStr +=  '<br/><table border="1" style="border-collapse: collapse"><thead><th>Field Label</th><th>Old Values</th><th>New Values</th></thead><tbody><tr><td width="25%">Last Modified By User</td><td width="25%">' +
                                getValueFromMap(userMap,schOld.LastModifiedById, 'Name')+'</td><td width="25%">'+ getValueFromMap(userMap,sch.LastModifiedById, 'Name') +'</td></tr><tr><td width="25%"><b>End Date</b></td><td width="25%"><b>' + 
                                ObjectToDate(schOld.End_Date__c) +'</b></td><td width="25%"><b>'+ ObjectToDate(sch.End_Date__c) +'</b></td></tr>';
               }
            }
            
            if((schType == 'Room Change' && room != null && room != '') || schType == 'Schedule Change' || (schType == 'Replace Instructor' && (instructor != null && instructor != ''))) {
                idWithMailBodyMap.putAll(formTable(tableStr, fieldMap, emailBody, o, oldMap, oldMapId, schType, userMap, ObjIdAndRecordMap, objType));
            } else if(schType == 'Substitute') {
               idWithMailBodyMap.put(o.Id, tableStr);
            } else if(schType == 'Extended') {
               extendedSchIdWithMailContentMap.putAll(formTable(tableStr, fieldMap, emailBody, o, oldMap, oldMapId, schType, userMap, ObjIdAndRecordMap, objType));
            }
        }
        
        mailWrap.idWithMailBodyMap = idWithMailBodyMap;
        mailWrap.subjectMap = schIdSubjectMap;
        
        return mailWrap;
    }
    
    // Method to send the mail
    public List<Messaging.SingleEmailMessage> sendMailMethod(Map<Id,String> idMailBodyMap, Map<Id,String> subjectMap, String sendEmailTo) {
    
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        
        System_Values__c sysVal = System_Values__c.getValues(sendEmailTo); 
        if (sysVal != null && sysVal.Value__c != null) {
            for (String st : sysVal.Value__c.split(',')) {
                sendTo.add(st);
            }
        }
        
        for(Id rId : idMailBodyMap.keyset()) {   
            
            List<String> sendToAddress = new List<String>();
           
            if(roomChangeSchMap.containsKey(rId)) {
                sendToAddress.add(getValueFromMap(userMap, getValueFromMap(projIdRecMap, roomChangeSchMap.get(rId).Project__c, 'Project_Manager__c') , 'Email'));
            } else {
                sendToAddress.addAll(sendTo);
            }
            
            System.debug(':::***:::sendToAddress:::'+sendToAddress);
            
            if(sendToAddress != null && sendToAddress.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);
                //mail.setToAddresses(new List<String> {'keerthika@softsquare.biz'});  //'karthiga@softsquare.biz', 
                //mail.setSubject(objectLabel +' Modified for: '+getValueFromMap(oldMap, rId, 'Name');
                mail.setSubject(subjectMap.get(rId));
                mail.sethtmlBody(idMailBodyMap != null && idMailBodyMap.size() > 0 && idMailBodyMap.containsKey(rId) ? idMailBodyMap.get(rId):'');
                mails.add(mail);
            }
        }
        return mails;
    }
    
    // Method to form the table but the table rows are formed in another method
    public Map<Id,String> formTable(String tableVal, Map<String, Schema.SObjectField> fieldMap, String emailBody, Sobject o, Map<Id,sobject> oldMap, Id oldMapId, String schType, Map<Id, User> userMap, Map<Id,Sobject> ObjIdAndRecordMap, String objName) {

        String mailContent = tableVal;
        String totEveHorStr = '';
        String otherFieldsStr = '';
        String lastModifiedFieldStr = '';
        
        Map<Id,String> idWithMailContentMap = new Map<Id,String>();
        Set<String> modifiedFldSet = new Set<String>();
        Set<String> daySet = new Set<String> {'monday__c', 'tuesday__c', 'wednesday__c', 'thursday__c', 'friday__c', 'saturday__c', 'sunday__c'};
        Map<String, String> dayValueMap = new Map<String, String>();
        Set<String> fieldsNeedForRoomChangeSch = new Set<String> {'lastmodifieddate', 'start_date__c', 'end_date__c'};
              
        for(String fn: fieldMap.keyset()) { 
            modifiedFldSet.add(fn);
                        
            if (fn != 'systemmodstamp' && o.get(fn) != oldMap.get(oldMapId).get(fn)) {
              
                Boolean addIns = true;
                
                if(fn == 'Id' || fn == 'Prior_Schedule__c' || (objName == 'Schedule__c' && ((fn == 'Instructor__c' && schType == 'Replace Instructor') || 
                fn == 'Name' || (schType == 'Room Change' && !fieldsNeedForRoomChangeSch.contains(fn)) || schType == 'Extended'))) {
                    addIns = false;
                }
                
                if(addIns) {
                    if(fn == 'Monday__c' || fn == 'Tuesday__c' || fn == 'Wednesday__c' || fn == 'Thursday__c' || fn == 'Friday__c' || fn == 'Saturday__c' || fn == 'Sunday__c') {
                        dayValueMap.put(fn, getTableRow(oldMap, fn, o, oldMapId, fieldMap, userMap, ObjIdAndRecordMap));
                    
                    } else if(fn == 'LastModifiedDate') {
                        lastModifiedFieldStr += getTableRow(oldMap, fn, o, oldMapId, fieldMap, userMap, ObjIdAndRecordMap);
                    
                    } else if(fn == 'Total_Events__c' || fn == 'Total_Hours__c' || fn == 'Total_Hours_Used__c' ) { // to avoid sending mail only when rollup is fields are updated 
                        totEveHorStr += getTableRow(oldMap, fn, o, oldMapId, fieldMap, userMap, ObjIdAndRecordMap);
                    
                    } else {
                        otherFieldsStr += getTableRow(oldMap, fn, o, oldMapId, fieldMap, userMap, ObjIdAndRecordMap);
                    }
                }
            } 
        }
        
        System.debug(':::***:::totEveHorStr:::'+totEveHorStr);
        
        if(otherFieldsStr != '') {
            mailContent += lastModifiedFieldStr+otherFieldsStr;
            
            if(totEveHorStr != '') { // Send mail for rollup fields updation when the other (except rollup) fields are updated along with rollup fields
                mailContent += totEveHorStr;
            }
        }
        
        if(dayValueMap != null && dayValueMap.size() > 0) {
            for(String str : daySet) {
                if(dayValueMap.containsKey(str)) {
                    mailContent += dayValueMap.get(str);
                }
            }
        }
        
        if(schType != 'Extended') {
            mailContent += '</tbody></table><br/><p>Thanks,</p><p>DLS</p><br/><p>This is a system generated email, Please do not respond.</p></html>';
        }
        
        System.debug(':::***:::Mail Content:::'+emailBody +mailContent);
      
        if(modifiedFldSet != null && modifiedFldSet.size() > 1 && (otherFieldsStr != '' || schType == 'Extended')) {
            idWithMailContentMap.put(o.Id,emailBody + mailContent );
        }  
        
        return idWithMailContentMap;
    }   
    
    // Method to form the table rows with Corresponding values
    public String getTableRow(Map<Id,sobject> oldMap, String fn, Sobject o, Id oldMapId, Map<String, Schema.SObjectField> fieldMap, Map<Id, User> userMap, Map<Id,Sobject> ObjIdAndRecordMap) {
        
        String tableStr = '';
        
        if(oldMap.get(oldMapId).get(fn) != null && o.get(fn) != null) {
                        
            if(fieldMap.get(fn).getDescribe().getRelationshipName() == 'LastModifiedBy') {
                tableStr += '<tr><td width="25%">Last Modified By User</td><td width="25%">'+getValueFromMap(userMap,getValueFromMap(oldMap, oldMapId, fn), 'Name')+'</td><td width="25%">'+getValueFromMap(userMap,String.ValueOf(o.get(fn)), 'Name') +'</td></tr>';                       
            } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Currency') {
                tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td><td width="25%">$'+getValueFromMap(oldMap, oldMapId, fn)+'</td><td width="25%">$'+o.get(fn)+'</td></tr>';                       
            } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'DateTime') {
                tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td><td width="25%">'+ObjectToDateTime(DateTime.valueOf(getValueFromMap(oldMap, oldMapId, fn)))+'</td><td width="25%">'+ObjectToDateTime(o.get(fn))+'</td></tr>';
            } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Date') {
                tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td><td width="25%">'+ObjectToDate(Date.valueOf(getValueFromMap(oldMap, oldMapId, fn)))+'</td><td width="25%">'+ObjectToDate(o.get(fn))+'</td></tr>';
            } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Reference') {
                tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td><td width="25%">' +returnName(ObjIdAndRecordMap,oldMap.get(oldMapId).get(fn))+'</td><td width="25%">'+returnName(ObjIdAndRecordMap,o.get(fn))+'</td></tr>';
            } else {
                tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td><td width="25%">'+getValueFromMap(oldMap, oldMapId, fn)+'</td><td width="25%">'+o.get(fn)+'</td></tr>';                       
            }
        } else {
            
            tableStr += '<tr><td width="25%">'+fieldMap.get(fn).getDescribe().getLabel()+'</td>';
            if(oldMap.get(oldMapId).get(fn) == null) {
                tableStr += '<td width="25%">'+''+'</td>';
            } else {
                if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Reference') {
                    tableStr += '<td width="25%">'+returnName(ObjIdAndRecordMap,oldMap.get(oldMapId).get(fn))+'</td>';
                } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'DateTime') {
                    tableStr += '<td width="25%">'+ObjectToDateTime(DateTime.valueOf(getValueFromMap(oldMap, oldMapId, fn)))+'</td>';    
                } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Date') {
                    tableStr += '<td width="25%">'+ObjectToDate(Date.valueOf(getValueFromMap(oldMap, oldMapId, fn)))+'</td>';    
                } else {
                    tableStr += '<td width="25%">'+(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Currency' ? '$' : '')+getValueFromMap(oldMap, oldMapId, fn)+'</td>';
                }
            }
            if(o.get(fn) == null) {
                tableStr += '<td width="25%">'+''+'</td></tr>';
            } else {
                if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Reference') {
                    tableStr += '<td width="25%">'+returnName(ObjIdAndRecordMap,o.get(fn))+'</td>';
                } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'DateTime') {
                    tableStr += '<td width="25%">'+ObjectToDateTime(o.get(fn))+'</td>';    
                } else if(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Date') {
                    tableStr += '<td width="25%">'+ObjectToDate(o.get(fn))+'</td>';    
                } else {
                    tableStr += '<td width="25%">'+(String.ValueOF(fieldMap.get(fn).getDescribe().getType()) == 'Currency' ? '$' : '')+o.get(fn)+'</td></tr>';
                }
            }
        }
        return tableStr;
    }
    
    // Method to get the value from map
    public string getValueFromMap(Map<Id, Sobject> sobjMap, String key, String fieldName) {
       
        String value = '';
        if(sobjMap != null && sobjMap.size() > 0 && sobjMap.containsKey(key)) {
            Sobject obj = sobjMap.get(key);
            
            if(fieldName == 'Total_Contract_Value_Options__c' || fieldName == 'Total_Events__c' || fieldName == 'Total_Hours__c' || fieldName == 'Total_Hours_Used__c') {
                value = (obj.get(fieldName) != null ? String.valueOf(obj.get(fieldName)) : '0');
            } else {
                value = (obj.get(fieldName) != null ? String.valueOf(obj.get(fieldName)) : '');
            }
        }
        return value;
    }
    
    // To send the mail for the completed schedule
    public void sendMailForComSchedule(Map<String, String> headerMap, List<Sobject> objList, String tableStr, Map<String, Map<Id, String>> refMap, String sub, String sendToAddress) {
        
        Map<Id, String> mailContentMap = new Map<Id, String>();
        tableStr += '<br/><table border="1" style="border-collapse: collapse"><thead>';
        
        for(String str : headerMap.keySet()) {
            tableStr += '<th>'+headerMap.get(str)+'</th>';
        }
        
        tableStr += '</thead>';
        for(Sobject obj : objList) {
            
            tableStr += '<tr>';
            for(String str : headerMap.keySet()) {
                
                if(refMap.containsKey(str)) { 
                    tableStr += '<td width="20%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + obj.get(Str) +'">' + (refMap.get(str).get((String)obj.get(str)) != null ? refMap.get(str).get((String)obj.get(str)) : '')+'</a></td>';
                } else if(str == 'Name') {
                     tableStr += '<td width="20%"><a href="'+ System.Label.Org_Prefix_Start_URL + '/' + obj.get('Id') +'">' + (obj.get(str) != null && obj.get(str) != ''? obj.get(str) : '') +'</a></td>';
                } else {
                    
                    if(str == 'Start_Date__c') {
                        tableStr += '<td width="20%">'+ (obj.get(str) != null && obj.get(str) != ''? ObjectToDate(obj.get(str)) : '') +'</td>';
                    } else {
                        tableStr += '<td width="20%">'+ (obj.get(str) != null && obj.get(str) != ''? obj.get(str) : '') +'</td>';
                    }
                }
            }
            tableStr += '</tr>';
        }
        
        tableStr += '</table><br/><p>Thanks,</p><p>DLS</p><br/><p>This is a system generated email, Please do not respond.</p></html>';
        
        List<Messaging.SingleEmailMessage> mailSend = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        for (String st : sendToAddress.split(',')) {
            sendTo.add(st);
        }
      
        mail.setToAddresses(sendTo);
        //mail.setToAddresses(new List<String> {'keerthika@softsquare.biz'});  //'karthiga@softsquare.biz', 
        mail.setSubject(sub);
        mail.sethtmlBody(tableStr);
        mailSend.add(mail);
        
        if( mailSend != null && mailSend.size() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(mailSend);
        }
    }
    
    // To form the table content related to events when the instructor is Substituted for schedule
    public void sendMailForSubSchedule(Map<Id, List<Events__c>> schIdEventsMap) {
        
        Map<Id, String> schIdTableContentMap = new Map<Id, String>();
        Map<Id, Decimal> eveTotalHrMap = new Map<Id, Decimal>();
        List<mailWrapper> mailWrap = new List<mailWrapper>(); 
        List<Messaging.SingleEmailMessage> mailSend = new List<Messaging.SingleEmailMessage>();
        
        
        if(subSchIdSet.size() > 0) {
            
            List<Schedule__c> schList = [SELECT Id, Name, Prior_Schedule__c, Instructor__c, Instructor__r.Name, Schedule_Type__c, LastModifiedById, Project__c, Project_Task__c, Room__c FROM Schedule__c WHERE Id IN :subSchIdSet];
            
            List<Events__c> eveList = new List<Events__c>();
            
            for(Id schId : schIdEventsMap.keySet()) {
                if(subSchIdSet.contains(schId)) {
                    eveList.addAll(schIdEventsMap.get(schId));
                }
            }
            
            for(Events__c eve : eveList) {
                
                String eventTableRow = '<tr><td width="25%">'+ObjectToDate(eve.Date__c)+'</td><td width="25%">'+eve.Start_Time__c+
                                        '</td><td width="25%">'+eve.End_Time__c+'</td><td width="25%">'+(eve.Duration__c != null ? eve.Duration__c : 0)+' hrs</td></tr>';
                if(!schIdTableContentMap.containsKey(eve.Schedule__c)) {
                    
                    eveTotalHrMap.put(eve.Schedule__c, (eve.Duration__c != null) ? eve.Duration__c : 0);
                    
                    String tableStr = '<br/><table border="1" style="border-collapse: collapse"><thead><th>Date(s)</th><th>Start Time</th><th>End Time</th><th>Total Hours</th></thead><tbody>';
                    schIdTableContentMap.put(eve.Schedule__c, tableStr+eventTableRow);
                
                } else {
                    
                    if(eve.Duration__c != null) {
                        eveTotalHrMap.put(eve.Schedule__c, eveTotalHrMap.get(eve.Schedule__c)+eve.Duration__c);
                    }
                    
                    schIdTableContentMap.put(eve.Schedule__c, schIdTableContentMap.get(eve.Schedule__c)+eventTableRow);
                }
            }
        
        
            if(eveTotalHrMap != null && eveTotalHrMap.size() > 0 && schIdTableContentMap != null && schIdTableContentMap.size() > 0) {
                for(Id schId : eveTotalHrMap.keySet()) {
                    String tableStr = 'TOTAL PLANNED QTY: </b>'+String.valueOf(eveTotalHrMap.get(schId) > 0 ? eveTotalHrMap.get(schId) : 0)+' hrs</p><br/><b>EVENTS:</b><br/>'+schIdTableContentMap.get(schId)+
                                      '</tbody></table><br/><p>Thanks,</p><p>DLS</p><br/><p>This is a system generated email, Please do not respond.</p></html>';
                    System.debug(':::***::Sub Mail Content:::'+tableStr);
                    schIdTableContentMap.put(schId, tableStr);
                }
            }
            
            if(schIdTableContentMap != null && schIdTableContentMap.size() > 0) {
                wrapSch.schIdTableStrMap = schIdTableContentMap;
                mailWrap.add(getSchTable(schList, null, 'Schedule__c', wrapSch));
            }
           
            if(mailWrap != null && mailWrap.size() > 0) {
                for(mailWrapper wrp : mailWrap) {
                    mailSend.addAll(sendMailMethod(wrp.idWithMailBodyMap, wrp.subjectMap, 'Schedule Update Notify Mail'));
                }
            }  
            
            if(mailSend != null && mailSend.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mailSend);
            }
        }
    }
    
    // To send the mail when the end date of the schedule is extended
    public void sendMailForExtendedSchedule(Map<Id, Schedule__c> exSchMap) {
        
        String tableStr = '';
        List<Messaging.SingleEmailMessage> mailSend = new List<Messaging.SingleEmailMessage>();
        
        for(String schId : extendedSchIdWithMailContentMap.keySet()) {
            
            tableStr = extendedSchIdWithMailContentMap.get(schId);
            tableStr += '<tr><td width="25%">Total # of Events</td><td width="25%">' + getValueFromMap(parentSchIdRecMap, schId, 'Total_Events__c') +
                        '</td><td width="25%">'+ (exSchMap.containsKey(schId) ? String.valueOf(exSchMap.get(schId).Total_Events__c) : getValueFromMap(parentSchIdRecMap, schId, 'Total_Events__c')) +
                        '</td></tr><tr><td width="25%">Total Qty Scheduled</td><td width="25%">'+getValueFromMap(parentSchIdRecMap, schId, 'Total_Hours__c') +'</td><td width="25%">'+ 
                        (exSchMap.containsKey(schId) ? String.valueOf(exSchMap.get(schId).Total_Hours__c) : getValueFromMap(parentSchIdRecMap, schId, 'Total_Hours__c')) +'</td></tr>'+
                        '</tbody></table><br/><p>Thanks,</p><p>DLS</p><br/><p>This is a system generated email, Please do not respond.</p></html>';
            
            extendedSchIdWithMailContentMap.put(schId, tableStr);
        }
        
        if(extendedSchIdWithMailContentMap != null && extendedSchIdWithMailContentMap.size() > 0) {
            mailSend.addAll(sendMailMethod(extendedSchIdWithMailContentMap, extendedSchIdSubjectMap, 'Schedule Update Notify Mail'));
        }  
        
        if(mailSend != null && mailSend.size() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(mailSend);
        }
    }
    
    public class commonWrapper {
        Map<Id,Sobject> ObjIdAndRecordMap = new Map<Id,Sobject>();
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
        Map<Id,User> usersMap = new Map<Id,User>();
        Map<Id, Contract> conrtMap = new Map<Id, Contract>();
        Map<Id,AcctSeed__Project__c> projMap = new Map<Id,AcctSeed__Project__c>();
        Map<Id,AcctSeed__Project_Task__c> proTaskMap = new Map<Id,AcctSeed__Project_Task__c>();
        Map<Id,Room__c> roomMap = new Map<Id,Room__c>();
        Map<Id, String> schIdTableStrMap = new Map<Id, String>();
        String objectLabel = '';
    }
    
    public class idSetObjFieldWrapper {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> projectTaskIdSet = new Set<Id>();
        Set<Id> roomIdSet = new Set<Id>();
        Map<String,Set<Id>> ObjectNameAndJointedIdMap = new Map<String,Set<Id>>();
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
        String objectLabel = '';
    }
    
    public class mailWrapper {
        Map<Id,String> idWithMailBodyMap = new Map<Id,String>();
        Map <Id, String> subjectMap = new Map<Id, String>();
    }
}