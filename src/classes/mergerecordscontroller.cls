public class mergerecordscontroller{
     
     public string survivorId{get;set;}
     public string destroyerId{get;set;} 
     public string destroyerId2{get;set;}    
     public sObject survivor{get;set;} 
     public sObject destroyer{get;set;}
     public sObject destroyer2{get;set;}
     public String survivorName{get;set;}
     public String destroyerName{get;set;}
     public String destroyerName2{get;set;}
     public List<sObject> survivorObjList{get;set;}
     public List<sObject> destroyerObjList{get;set;}
     public List<sObject> destroyerObjList2{get;set;}
     public Boolean isValid{get;set;}
     public String objectName{get;set;}
     public String objectNameField{get;set;}
     public String objectLabel{get;set;}
     public Map<String,String> FieldNameAndLableMap{get;set;}
     public Map<String,String> FieldNameAndTypeMap{get;set;}
     public Set<Id> parentRecordIdSet{get;set;}
     public Set<String> parentObjectNameSet{get;set;}
     public Map<Id,sObject> ObjIdAndRecordMap{Get;set;}
     public Map<String,String> ChildObjNameAndRelatedFieldMap{get;set;}
     public Map<String,String> ChildObjNameAndRelatedChildNameMap{get;set;}
     public Map<String,List<sObject>> survivorChildObjectMap{get;set;}
     public Map<String,List<sObject>> destroyerChildObjectMap{get;set;}
     public Map<String,List<sObject>> destroyerChildObjectMap2{get;set;}
     public Map<String,List<sObject>> reparentChildObjectMap{get;set;}
     public Map<String,List<sObject>> reparentChildObjectMap2{get;set;}
     public Map<String,String> objApiNameAndLabelMap{get;set;}
     public Map<String,String> objApiNameAndNameFieldMap{get;set;}
     public Map<Id,String>ObjParentIdAndObjectNameMap{get;set;}
     public Map<String,Boolean> objApiNameAndReparentableBooleanMap{get;set;}
     public Map<Id, String> errorRecordIdNameMap{get; set;}
     public Set<Id> errorRecordId = new Set<Id>();
     public Boolean enableactivity;
     public Boolean error;
 
     
     // Inner Class initialization
     
     public List<GeneralInfo> GeneralInfoList{get;set;}
     public List<String> GeneralFields{get;set;}
     public List<String> ReadOnlyFields{get;set;}
     public List<String> AllFieldsList{get;set;}
     public List<ReadOnlyInfo> ReadOnlyInfoList{Get;set;}
     public List<ReparantableInfo> ReparantableChildList{get;set;}
     public List<NotReparantableInfo> NotReparantableChildList{get;set;}
     
     public class GeneralInfo{       
        public String choice{get;set;}
        public String objFieldLabel{get;set;}
        public String objFieldName{get;set;}
        public String objFieldOneValue{get;set;}
        public String objFieldOneReferenceName{get;set;}
        public String objFieldTwoValue{get;set;}
        public String objFieldTwoReferenceName{get;set;}
        public String objFieldThreeValue{get;set;}
        public String objFieldThreeReferenceName{get;set;}
        public String SelectedValue{get;set;}
        public Boolean isHighLighted{get;set;}
    }
    
    public class ReadOnlyInfo{       
        public String choice{get;set;}
        public String objFieldLabel{get;set;}
        public String objFieldName{get;set;}
        public String objFieldOneValue{get;set;}
        public String objFieldOneReferenceName{get;set;}
        public String objFieldTwoValue{get;set;}
        public String objFieldTwoReferenceName{get;set;}
        public String objFieldThreeValue{get;set;}
        public String objFieldThreeReferenceName{get;set;}
        public String SelectedValue{get;set;}
    }
    
    public class ReparantableInfo{       
        public String objectName{get;set;}
        public String objectLabel{get;set;}
        public integer childonelistsize{get;set;}
        public integer childtwolistsize{get;set;}
        public integer childthreelistsize{get;set;}
    }
    
    public class NotReparantableInfo{       
        public String objectName{get;set;}
        public String objectLabel{get;set;}
        public integer childonelistsize{get;set;}
        public integer childtwolistsize{get;set;}
        public integer childthreelistsize{get;set;}
    }
  
     public mergerecordscontroller() {
         
         survivorObjList = new List<sObject>();
         destroyerObjList = new List<sObject>();
         destroyerObjList2 = new List<sObject>();     
         isValid = false; 
         GeneralInfoList = new List<GeneralInfo>();
         GeneralFields = new List<String>();
         ReadOnlyFields = new List<String>();
         AllFieldsList = new List<String>();
         ReadOnlyInfoList = new List<ReadOnlyInfo>();
         parentRecordIdSet = new Set<Id>();
         parentObjectNameSet = new Set<String>();
         
         FieldNameAndLableMap = new Map<String,String>();
         FieldNameAndTypeMap = new Map<String,String>();
         ChildObjNameAndRelatedFieldMap = new Map<String,String>();
         ChildObjNameAndRelatedChildNameMap = new Map<String,String>();
         ObjParentIdAndObjectNameMap = new Map<Id,String>();
         ObjIdAndRecordMap = new Map<Id,sObject>();
         survivorChildObjectMap = new Map<String,List<sObject>>();
         destroyerChildObjectMap = new Map<String,List<sObject>>();
         destroyerChildObjectMap2 = new Map<String,List<sObject>>();
         objApiNameAndLabelMap = new Map<String,String>();
         ReparantableChildList= new List<ReparantableInfo>();
         NotReparantableChildList= new List<NotReparantableInfo>();
         errorRecordIdNameMap = new Map<Id, String>();
         objApiNameAndReparentableBooleanMap = new Map<String,Boolean>();
         reparentChildObjectMap = new Map<String,List<sObject>>();
         reparentChildObjectMap2 = new Map<String,List<sObject>>();
         objApiNameAndNameFieldMap = new Map<String,String>();
         enableactivity = false;
 
         error = false;
 
         survivorId = ApexPages.currentPage().getParameters().get('RecordOneId');
         destroyerId = ApexPages.currentPage().getParameters().get('RecordTwoId');
         destroyerId2 = ApexPages.currentPage().getParameters().get('RecordThreeId');  
         
         if((survivorId != NULL && survivorId != '' && destroyerId != NULL && destroyerId != '') || (destroyerId2 != null && destroyerId2 != '')){
             
             if( (( survivorId.length() == 15 ||survivorId.length() == 18) && ( destroyerId.length() == 15 || destroyerId.length() == 18)) || (destroyerId2 != null && destroyerId2 != '' && (destroyerId2.length() == 15 || destroyerId2.length() == 18)) ){
                 
                 Id tempIdOne = survivorId;
                 Id tempIdTwo = destroyerId;
                 Id tempIdThree = (destroyerId2 != null && destroyerId2 != '') ? destroyerId2 : null;
                 
                 try{
                     objectName = tempIdOne.getSObjectType().getDescribe().getName();                    
                     String tempObjectName = tempIdTwo.getSObjectType().getDescribe().getName();
                     String tempObjectName2 = (tempIdThree != null) ? tempIdThree.getSObjectType().getDescribe().getName() : null; 
                                         
                     if((tempObjectName2 == null && objectName.equalsIgnoreCase(tempObjectName)) || (tempObjectName2 != null && objectName.equalsIgnoreCase(tempObjectName) && tempObjectName.equalsIgnoreCase(tempObjectName2) && objectName.equalsIgnoreCase(tempObjectName2))) {
                         if((tempIdThree == null && tempIdOne != tempIdTwo) || (tempIdThree != null && tempIdOne != tempIdTwo && tempIdTwo != tempIdThree && tempIdOne != tempIdThree)) {
                             isValid = true;
                             objectLabel = tempIdOne.getSObjectType().getDescribe().getLabel(); 
                         }
                     }
                 }catch(Exception e){
                    // system.debug('::::exception::'+e);
                 } 
                                 
             }                      
         }
         
         if(isValid == true) {
              
              
              Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
              
              for(Schema.SObjectType sch : globalDescription.Values()) {
                Schema.DescribeSObjectResult dsr = sch.getDescribe();
                objApiNameAndLabelMap.put(dsr.getName(),dsr.getLabel());
                objApiNameAndReparentableBooleanMap.put(dsr.getName(),dsr.isUpdateable());
              }
             // System.debug(':::objApiNameAndReparentableBooleanMap:::'+objApiNameAndReparentableBooleanMap);
              String queryStringOne = 'SELECT ';
              String queryStringTwo = 'SELECT ';
              String queryStringThree = 'SELECT ';
              
              Id tempid = survivorId;
              Map <String, Schema.SObjectField> fieldMap = tempid.getSObjectType().getDescribe().fields.getMap();
 
              for(Schema.SObjectField sfield : fieldMap.Values()) {
                  schema.describefieldresult dfield = sfield.getDescribe();
                  if(dfield.getname() != 'Id') {
                      if(dfield.isNameField()){
                        objectNameField = dfield.getname();
                      }
                  
                      if(fieldMap.containsKey(dfield.getname()) && fieldMap.get(dfield.getname()).getDescribe().isUpdateable()) {
                          GeneralFields.add(dfield.getname());
                      }else{
                          ReadOnlyFields.add(dfield.getname()); 
                      }
                      AllFieldsList.add(dfield.getname());
                      FieldNameAndLableMap.put(dfield.getname(),dfield.getLabel());
                      FieldNameAndTypeMap.put(dfield.getname(),String.valueOf(dfield.getType()));
                      queryStringOne += dfield.getname() + ',';
                      queryStringTwo += dfield.getname() + ',';
                      if (destroyerId2 != null && destroyerId2 != '') {
                          queryStringThree += dfield.getname() + ',';
                      }                      
                  }
              }
              FieldNameAndLableMap.put('AAA','Master Record');
              GeneralFields.add('AAA');
              
              queryStringOne += 'Id FROM '+objectName+ ' WHERE Id =\'' + survivorId + '\'';
              queryStringTwo += 'Id FROM '+objectName+ ' WHERE Id =\'' + destroyerId + '\'';
              
            //  system.debug('::::queryStringOne:::'+queryStringOne);
           //   system.debug('::::queryStringTwo:::'+queryStringTwo );
           //   system.debug('::::queryStringThree:::'+queryStringThree);
              
              survivorObjList = Database.query(queryStringOne);
              destroyerObjList = Database.query(queryStringTwo);
              if (destroyerId2 != null && destroyerId2 != '') {
                  queryStringThree += 'Id FROM '+objectName+ ' WHERE Id =\'' + destroyerId2 + '\'';
                  destroyerObjList2 = Database.query(queryStringThree);
              }
              
              if((destroyerId2 != null && destroyerId2 != '' && survivorObjList != NULL && survivorObjList.size() > 0 && destroyerObjList != NULL && destroyerObjList.size() > 0 && destroyerObjList2 != NULL && destroyerObjList2.size() > 0) ||
              ((destroyerId2 == null || destroyerId2 == '') && survivorObjList != NULL && survivorObjList.size() > 0 && destroyerObjList != NULL && destroyerObjList.size() > 0)){
                 
                  survivor = survivorObjList[0];
                  destroyer = destroyerObjList[0];
                  if (destroyerId2 != null && destroyerId2 != '') {
                      destroyer2 = destroyerObjList2[0];
                      destroyerName2 = (destroyer2.get(objectNameField) != NULL) ? String.valueOf(destroyer2.get(objectNameField)) : null;
                  }
                  survivorName = (survivor.get(objectNameField) != NULL) ? String.valueOf(survivor.get(objectNameField)) : null;
                  destroyerName = (destroyer.get(objectNameField) != NULL) ? String.valueOf(destroyer.get(objectNameField)) : null;
                  
                  // Get Parent Record using arentRecords Method --
                  
                  for(String fieldstr : AllFieldsList){
                      
                      if(FieldNameAndTypeMap.containsKey(fieldstr) && FieldNameAndTypeMap.get(fieldstr) != NULL) {
                            if(FieldNameAndTypeMap.get(fieldstr).equalsIgnoreCase('Reference')) {
                                if(survivor.get(fieldstr) != NULL) {
                                    parentRecordIdSet.add(String.valueOf(survivor.get(fieldstr)));
                                }
                                if(destroyer.get(fieldstr) != NULL) {
                                    parentRecordIdSet.add(String.valueOf(destroyer.get(fieldstr)));
                                }
                                if(destroyerId2 != null && destroyerId2 != '' && destroyer2.get(fieldstr) != NULL) {
                                    parentRecordIdSet.add(String.valueOf(destroyer2.get(fieldstr)));
                                }
                            }
                      }
                  }
              //    system.debug('::::serrr::'+parentRecordIdSet);
                  
                  for(Id parentid : parentRecordIdSet){
                     parentObjectNameSet.add(parentid.getSObjectType().getDescribe().getName());
                     ObjParentIdAndObjectNameMap.put(parentid,parentid.getSObjectType().getDescribe().getName());
                  }
                  
                   // Get Parent Object Names -----
                  
                  for(Schema.SObjectType sch : globalDescription.Values()) {
                        
                    Schema.DescribeSObjectResult dsr = sch.getDescribe();
                    if(parentObjectNameSet.contains(dsr.getName())) {
                        for(Schema.SObjectField sfield :dsr.fields.getMap().values()){
                            schema.describefieldresult dfield =  sfield.getDescribe();
                           // System.debug(':::dfield::'+dfield);
                            if(dfield.isNameField()){
                                objApiNameAndNameFieldMap.put(dsr.getName(),dfield.getName());
                            }
                        }
                     }
                  }
                  
               //   system.debug('::ObjParentIdAndObjectNameMap:::'+ObjParentIdAndObjectNameMap);
               //   system.debug('::objApiNameAndNameFieldMap:::'+objApiNameAndNameFieldMap);
                  
                  if(parentRecordIdSet.size() > 0){
                        getParentRecords(parentRecordIdSet);
                  }
           
                  Integer k;
                  GeneralFields.sort();
                  for(k = 0; k < GeneralFields.size();k++) {
          
                      GeneralInfo gi = new GeneralInfo();
                      gi.choice = 'gen' + String.valueOf(k);
                      if(FieldNameAndLableMap.containsKey(GeneralFields[k]) && FieldNameAndLableMap.get(GeneralFields[k]) != NULL) {
                          gi.objFieldLabel= FieldNameAndLableMap.get(GeneralFields[k]);
                      }
                      if(GeneralFields[k] != 'AAA') {
                          gi.objFieldName = GeneralFields[k];
                          gi.objFieldOneValue = (survivor.get(GeneralFields[k]) != NULL) ? String.valueOf(survivor.get(GeneralFields[k])) : null;
                          gi.objFieldTwoValue = (destroyer.get(GeneralFields[k]) != NULL) ? String.valueOf(destroyer.get(GeneralFields[k])) : null;
                          gi.objFieldThreeValue = (destroyerId2 != null && destroyerId2 != '' && destroyer2.get(GeneralFields[k]) != NULL) ? String.valueOf(destroyer2.get(GeneralFields[k])) : null;
                          gi.isHighLighted = false;
                         
                          // Find reference obj name 
                         
                          if(FieldNameAndTypeMap.containsKey(GeneralFields[k]) && FieldNameAndTypeMap.get(GeneralFields[k]) != NULL) {
                             if(FieldNameAndTypeMap.get(GeneralFields[k]).equalsIgnoreCase('Reference')){
                                 if(gi.objFieldOneValue != NULL && gi.objFieldOneValue != ''){
                                    String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(gi.objFieldOneValue));
                                    if(ObjIdAndRecordMap.containsKey(gi.objFieldOneValue) && ObjIdAndRecordMap.get(gi.objFieldOneValue) != NULL){
                                        gi.objFieldOneReferenceName = (ObjIdAndRecordMap.get(gi.objFieldOneValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(gi.objFieldOneValue).get(tempnameField)) : null;
                                    }
                                 }
                                 if(gi.objFieldTwoValue != NULL && gi.objFieldTwoValue != ''){
                                    String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(gi.objFieldTwoValue));
                                    if(ObjIdAndRecordMap.containsKey(gi.objFieldTwoValue) && ObjIdAndRecordMap.get(gi.objFieldTwoValue) != NULL){
                                        gi.objFieldTwoReferenceName = (ObjIdAndRecordMap.get(gi.objFieldTwoValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(gi.objFieldTwoValue).get(tempnameField)) : null;
                                    }
                                 }
                                 if(gi.objFieldThreeValue != NULL && gi.objFieldThreeValue != ''){
                                    String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(gi.objFieldThreeValue));
                                    if(ObjIdAndRecordMap.containsKey(gi.objFieldThreeValue) && ObjIdAndRecordMap.get(gi.objFieldThreeValue) != NULL){
                                        gi.objFieldThreeReferenceName = (ObjIdAndRecordMap.get(gi.objFieldThreeValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(gi.objFieldThreeValue).get(tempnameField)) : null;
                                    }
                                 }
                             }
                          }
                      }else{
                           gi.objFieldOneReferenceName = (survivor.get(objectNameField) != NULL) ? String.valueOf(survivor.get(objectNameField)) : null;
                           gi.objFieldTwoReferenceName = (destroyer.get(objectNameField) != NULL) ? String.valueOf(destroyer.get(objectNameField)) : null;
                           gi.objFieldThreeReferenceName = (destroyerId2 != null && destroyerId2 != '' && destroyer2.get(objectNameField) != NULL) ? String.valueOf(destroyer2.get(objectNameField)) : null;
                           gi.objFieldOneValue = (survivor.get('Id') != NULL) ? String.valueOf(survivor.get('Id')) : null;
                           gi.objFieldTwoValue = (destroyer.get('Id') != NULL) ? String.valueOf(destroyer.get('Id')) : null;
                           gi.objFieldThreeValue = (destroyerId2 != null && destroyerId2 != '' && destroyer2.get('Id') != NULL) ? String.valueOf(destroyer2.get('Id')) : null;
                           gi.isHighLighted = true;
                      }
                      GeneralInfoList.add(gi);
                 }      
                 Integer m;
                 ReadOnlyFields.sort();
              //   system.debug(':::'+ReadOnlyFields.size());
                  for(m = 0; m < ReadOnlyFields.size();m++) {
                     
                      ReadOnlyInfo roi = new ReadOnlyInfo();
                      if(FieldNameAndLableMap.containsKey(ReadOnlyFields[m]) && FieldNameAndLableMap.get(ReadOnlyFields[m]) != NULL) {
                          roi.objFieldLabel= FieldNameAndLableMap.get(ReadOnlyFields[m]);
                      }
                      roi.objFieldName = ReadOnlyFields[m];
                      roi.objFieldOneValue = (survivor.get(ReadOnlyFields[m]) != NULL) ? String.valueOf(survivor.get(ReadOnlyFields[m])) : null;
                      roi.objFieldTwoValue = (destroyer.get(ReadOnlyFields[m]) != NULL) ? String.valueOf(destroyer.get(ReadOnlyFields[m])) : null;
                      roi.objFieldThreeValue = (destroyerId2 != null && destroyerId2 != '' && destroyer2.get(ReadOnlyFields[m]) != NULL) ? String.valueOf(destroyer2.get(ReadOnlyFields[m])) : null;
                      
                      // Field Name for Reference --
                      if(FieldNameAndTypeMap.containsKey(ReadOnlyFields[m]) && FieldNameAndTypeMap.get(ReadOnlyFields[m]) != NULL) {
                         if(FieldNameAndTypeMap.get(ReadOnlyFields[m]).equalsIgnoreCase('Reference')){
                             if(roi.objFieldOneValue != NULL && roi.objFieldOneValue != ''){
                                String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(roi.objFieldOneValue));
                                if(ObjIdAndRecordMap.containsKey(roi.objFieldOneValue) && ObjIdAndRecordMap.get(roi.objFieldOneValue) != NULL){
                                    roi.objFieldOneReferenceName = (ObjIdAndRecordMap.get(roi.objFieldOneValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(roi.objFieldOneValue).get(tempnameField)) : null;
                                }
                             }
                             if(roi.objFieldTwoValue != NULL && roi.objFieldTwoValue != ''){
                                String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(roi.objFieldTwoValue));
                                if(ObjIdAndRecordMap.containsKey(roi.objFieldTwoValue) && ObjIdAndRecordMap.get(roi.objFieldTwoValue) != NULL){
                                    roi.objFieldTwoReferenceName = (ObjIdAndRecordMap.get(roi.objFieldTwoValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(roi.objFieldTwoValue).get(tempnameField)) : null;
                                }
                             }
                             if(roi.objFieldThreeValue != NULL && roi.objFieldThreeValue != ''){
                                String tempnameField = objApiNameAndNameFieldMap.get(ObjParentIdAndObjectNameMap.get(roi.objFieldThreeValue));
                                if(ObjIdAndRecordMap.containsKey(roi.objFieldThreeValue) && ObjIdAndRecordMap.get(roi.objFieldThreeValue) != NULL){
                                    roi.objFieldThreeReferenceName = (ObjIdAndRecordMap.get(roi.objFieldThreeValue).get(tempnameField) != NULL) ? String.valueOf(ObjIdAndRecordMap.get(roi.objFieldThreeValue).get(tempnameField)) : null;
                                }
                             }
                         }
                      }
                      ReadOnlyInfoList.add(roi); 
                 }      
                // ---------  Get Child object results ---
                
                List<Schema.ChildRelationship> childlist = tempid.getSObjectType().getDescribe().getChildRelationships(); 
                
                getChildRecords(survivorId,childlist);
                getChildRecords(destroyerId,childlist);
                if (destroyerId2 != null && destroyerId2 != '') {
                    getChildRecords(destroyerId2,childlist);
                }
              
                for(Schema.SObjectType sch : globalDescription.Values()) {
                    
                    Schema.DescribeSObjectResult dsr = sch.getDescribe();
                    if(dsr.isUpdateable()){
                        if(ChildObjNameAndRelatedChildNameMap.containsKey(dsr.getName())){
                            for(Schema.SObjectField sfield :dsr.fields.getMap().values()){
                               schema.describefieldresult dfield =  sfield.getDescribe();
                                if(dfield.getName() == ChildObjNameAndRelatedFieldMap.get(dsr.getName())){
                                 
                                     if(dfield.isUpdateable() == false) {
                                        objApiNameAndReparentableBooleanMap.put(dsr.getName(),false);
                                     }
                                }
                            }
                        }
                    }
                }
                
                // Check notes and attachment are enabled or not ---
                
                /*Merge_Sobjects__c mergeobj = Merge_Sobjects__c.getValues('Merge Records');
                enableactivity = mergeobj.Enable_activities__c; */
                
            //    system.debug(':::enable:::'+enableactivity); 
            //    System.debug('::::objApiNameAndReparentableBooleanMap con::::'+objApiNameAndReparentableBooleanMap.get('Contact'));

                if(enableactivity == true){
                    objApiNameAndReparentableBooleanMap.put('Note',true);
                    objApiNameAndReparentableBooleanMap.put('Attachment',true);
                } 
                
             //   System.debug(':::objApiNameAndReparentableBooleanMap::::'+objApiNameAndReparentableBooleanMap);
                for(String objname : ChildObjNameAndRelatedChildNameMap.keyset()){
              //      System.debug(':::objname::::'+objname);
                //    System.debug(':::objApiNameAndReparentableBooleanMap get ::::'+objApiNameAndReparentableBooleanMap.get(objname));
                    if(objApiNameAndReparentableBooleanMap.containsKey(objname) && objApiNameAndReparentableBooleanMap.get(objname) != NULL ) {
                        if(objApiNameAndReparentableBooleanMap.get(objname) == true) {
                            ReparantableInfo rpi = new ReparantableInfo();
                        //    System.debug(':::destroyerChildObjectMap2::::'+destroyerChildObjectMap2.get(objname));
                            rpi.objectName = objname;
                            if(objApiNameAndLabelMap.get(objname) != NULL){
                                rpi.objectLabel = objApiNameAndLabelMap.get(objname);
                            }
                            if(survivorChildObjectMap.get(objname) != NULL){
                                rpi.childonelistsize = survivorChildObjectMap.get(objname).size();
                            }else{
                                rpi.childonelistsize = 0;
                            }
                            if(destroyerChildObjectMap.get(objname) != NULL){
                                rpi.childtwolistsize = destroyerChildObjectMap.get(objname).size();
                            }else{
                                rpi.childtwolistsize = 0;
                            }
                            if(destroyerId2 != null && destroyerId2 != '' && destroyerChildObjectMap2.get(objname) != NULL){
                                rpi.childthreelistsize = destroyerChildObjectMap2.get(objname).size();
                            }else{
                                rpi.childthreelistsize = 0;
                            }
                       //     System.debug(':::rpi::::'+rpi);
                        //    System.debug(':::rpi three::::'+rpi.childthreelistsize);
                            ReparantableChildList.add(rpi);
                        }else{
                            NotReparantableInfo nrpi = new NotReparantableInfo();
                            nrpi.objectName = objname;
                            if(objApiNameAndLabelMap.get(objname) != NULL){
                                nrpi.objectLabel = objApiNameAndLabelMap.get(objname);
                            }
                         //   system.debug('::objlabel::'+nrpi.objectLabel);
                            if(survivorChildObjectMap.get(objname) != NULL){
                                nrpi.childonelistsize = survivorChildObjectMap.get(objname).size();
                            }else{
                                nrpi.childonelistsize = 0;
                            } 
                        //    system.debug('::objname::'+objname);
                            if(destroyerChildObjectMap.get(objname) != NULL){
                                nrpi.childtwolistsize = destroyerChildObjectMap.get(objname).size();
                            }else{
                                nrpi.childtwolistsize = 0;
                            }
                            if(destroyerId2 != null && destroyerId2 != '' && destroyerChildObjectMap2.get(objname) != NULL){
                                nrpi.childthreelistsize = destroyerChildObjectMap2.get(objname).size();
                            }else{
                                nrpi.childthreelistsize = 0;
                            }
                            NotReparantableChildList.add(nrpi);                         
                        }
                    }
                }
            //    system.debug('::ReparantableChildList:::'+ReparantableChildList);
           //     system.debug('::NotReparantableChildList:::'+NotReparantableChildList);
              }else{
                  isValid = false; 
              }
                      
         }
         
     }
     
     public void getParentRecords(Set<Id> parentRecordIdSet){
        
        Map<String,Set<Id>> ObjectNameAndIdSetMap = new Map<String,Set<Id>>();
        
        if(parentRecordIdSet.size() > 0) {
            
            for(Id ids : parentRecordIdSet){
                
                String temprecordidname = ids.getSObjectType().getDescribe().getName(); 
                Set<Id> tempidset = new Set<Id>();
                
                if(ObjectNameAndIdSetMap.containsKey(temprecordidname) && ObjectNameAndIdSetMap.get(temprecordidname) != NULL) {
                    tempidset = ObjectNameAndIdSetMap.get(temprecordidname);
                    tempidset.add(ids);
                    ObjectNameAndIdSetMap.put(temprecordidname,tempidset);
                }else{
                    tempidset.add(ids);
                    ObjectNameAndIdSetMap.put(temprecordidname,tempidset);
                }
            
            }
        }
        
        if(ObjectNameAndIdSetMap.size() > 0){
            
            Map<String,String> ObjectNameAndJointedIdMap = new Map<String,String>();
            
            for(String str : ObjectNameAndIdSetMap.keyset()){
                
                String concateidstring = '(';
                for(String idstr: ObjectNameAndIdSetMap.get(str)){
                    
                    concateidstring += '\''+idstr + '\',';
                }
                concateidstring = concateidstring.substring(0,concateidstring.length()-1) + ')';
                ObjectNameAndJointedIdMap.put(str,concateidstring);
            }
            
         //   system.debug(':::ObjectNameAndJointedIdMap::'+ObjectNameAndJointedIdMap);
            
            if(ObjectNameAndJointedIdMap.size() > 0) {
                
                for(String objnam : ObjectNameAndJointedIdMap.keyset()){
                    
                    String multiplequerystr = 'SELECT Id,'+objApiNameAndNameFieldMap.get(objnam)+' FROM ';
                    multiplequerystr += objnam + ' WHERE Id IN ' + ObjectNameAndJointedIdMap.get(objnam);
             //       system.debug(':::multiquery::'+multiplequerystr);
                    for(sObject sobj : Database.query(multiplequerystr)){
                        ObjIdAndRecordMap.put(String.valueOf(sobj.get('Id')),sobj);
                    }
                }
                
            }
         //   system.debug(':::ObjIdAndRecordMap:::'+ObjIdAndRecordMap);
        }
        
     }
     
     public void getChildRecords(String currentRecordId,List<Schema.ChildRelationship> childlist){
        
        if(childlist != NULL && childlist.size() > 0 && currentRecordId != NULL && currentRecordId != '' ){
            for(Schema.ChildRelationship schchild : childlist){
                if(schchild.getRelationshipName() != null){
              //      system.debug('::::child:'+String.valueOf(schchild.getChildsObject()));
                    if(String.valueOf(schchild.getChildsObject()) != 'OpenActivity' && String.valueOf(schchild.getChildsObject()) != 'ActivityHistory' && String.valueOf(schchild.getChildsObject()) != 'NoteAndAttachment' && String.valueOf(schchild.getChildsObject()) != 'CombinedAttachment') {
                        ChildObjNameAndRelatedFieldMap.put(String.valueOf(schchild.getChildsObject()),String.valueOf(schchild.getField()));
                        ChildObjNameAndRelatedChildNameMap.put(String.valueOf(schchild.getChildsObject()),String.valueOf(schchild.getRelationshipName()));
                    }
                }
            }     
        
            
            List<List<String>> listOfRelationshipNameList = new List<List<String>>();
             
             integer i = 0;
             integer j = 20;
             List<String> tempstringlist = new List<String>();
             
             for(String str : ChildObjNameAndRelatedChildNameMap.keyset()){
                
                if( i < j){
                    tempstringlist.add(str);    
                    if(ChildObjNameAndRelatedChildNameMap.keyset().size()-1 == i){
                        listOfRelationshipNameList.add(tempstringlist);
                    }
                }else{
                    
                    listOfRelationshipNameList.add(tempstringlist);
                    tempstringlist = new List<String>();
                    tempstringlist.add(str);    
                    j = j + j;
                }
                i++;
             }
         //   System.debug('::::ChildObjNameAndRelatedChildNameMap::::'+ChildObjNameAndRelatedChildNameMap);
        //    System.debug('::::ChildObjNameAndRelatedChildNameMap keyset::::'+ChildObjNameAndRelatedChildNameMap.keySet());
        //    System.debug(':::::::'+ChildObjNameAndRelatedChildNameMap.containsKey('Contact'));
            
      //      System.debug('::::listOfRelationshipNameList::::'+listOfRelationshipNameList);
            
            List<sObject> ChildObjList = new List<sObject>();
            
            for(List<String> strlist : listOfRelationshipNameList){
        //        System.debug('::::strlist::::'+strlist);
                
                String childquerystring  = 'SELECT Id,'+objectnameField+',';
                integer p = 0;
                for(String tempobjectname : strlist){
              //      System.debug('::::tempobjectname::::'+tempobjectname);
                    if(p < 20) {
                        String innerchildstring = '(SELECT Id FROM '+ ChildObjNameAndRelatedChildNameMap.get(tempobjectname) + ' LIMIT 100),';
              //          System.debug('::::innerchildstring::::'+innerchildstring);
                        childquerystring += innerchildstring;
                    }
                    p += 1; 
                }
                
                childquerystring = childquerystring.substring(0,childquerystring.length() -1);
                childquerystring += ' FROM ' + objectName + ' WHERE Id =\''+ currentRecordId + '\'';
                
                for(sObject  sobj : Database.query(childquerystring)){
                    ChildObjList.add(sobj);
                }
            }
            Integer r = 0;
         
            if(ChildObjList != NULL && ChildObjList.size() > 0 ){
                for(List<String> strlist : listOfRelationshipNameList){                    
                    Id tempId = String.valueOf(ChildObjList[r].get('Id'));
                    for(String objname : strlist){
                        if(objname != NULL && objname != ''){
                            if(ChildObjList[r].getSObjects(ChildObjNameAndRelatedChildNameMap.get(objname)) != null){
                                if(Id.valueOf(survivorId) == tempId){
                                    survivorChildObjectMap.put(objname,ChildObjList[r].getSObjects(ChildObjNameAndRelatedChildNameMap.get(objname)));
                                }else if(Id.valueOf(destroyerId) == tempId){
                                    destroyerChildObjectMap.put(objname,ChildObjList[r].getSObjects(ChildObjNameAndRelatedChildNameMap.get(objname)));
                                }else if(destroyerId2 != null && destroyerId2 != '' && Id.valueOf(destroyerId2) == tempId){
                                    destroyerChildObjectMap2.put(objname,ChildObjList[r].getSObjects(ChildObjNameAndRelatedChildNameMap.get(objname)));
                                }
                            }
                        }
                    } 
                    r++;
                } 
            } 
        } 
     }

     public PageReference mergerecords(){
        
        sObject finalSurvivor;
        sObject finalDestroyer;
        sObject finalDestroyer2;
        
        // Deciding survivor and destroyer ------

        if(GeneralInfoList != NULL && GeneralInfoList.size() > 0) {
            if(GeneralInfoList[0].SelectedValue != ''){
                Id tempid = GeneralInfoList[0].SelectedValue;

                if (destroyerId2 != null && destroyerId2 != '') {
                    if(tempid == Id.valueOf(survivorId)) {
                        finalSurvivor = survivor;
                        finalDestroyer = destroyer;
                        finalDestroyer2 = destroyer2;

                        reparentChildObjectMap = destroyerChildObjectMap.Clone();
                        reparentChildObjectMap2 = destroyerChildObjectMap2.Clone();
                    }else if(tempid == Id.valueOf(destroyerId)){
                        finalSurvivor = destroyer;
                        finalDestroyer = survivor;
                        finalDestroyer2 = destroyer2;
                        reparentChildObjectMap = survivorChildObjectMap.Clone();
                        reparentChildObjectMap2 = destroyerChildObjectMap2.Clone();
                    }else if(tempid == Id.valueOf(destroyerId2)){
                        finalSurvivor = destroyer2;
                        finalDestroyer = survivor;
                        finalDestroyer2 = destroyer;
                        reparentChildObjectMap = survivorChildObjectMap.Clone();
                        reparentChildObjectMap2 = destroyerChildObjectMap.Clone();
                    }
                } else {
                    if(tempid == Id.valueOf(survivorId)) {
                        finalSurvivor = survivor;
                        finalDestroyer = destroyer;
                        reparentChildObjectMap = destroyerChildObjectMap.Clone();                                                
                      
                    }else if(tempid == Id.valueOf(destroyerId)){
                        finalSurvivor = destroyer;
                        finalDestroyer = survivor;
                        reparentChildObjectMap = survivorChildObjectMap.Clone();
                    }
                }
               
            }
        }       
        
        system.debug('::::::::::reparentChildObjectMap::1::::'+reparentChildObjectMap);
        system.debug('::::::::::reparentChildObjectMap2::1::::'+reparentChildObjectMap2);
        
        if(reparentChildObjectMap != Null && reparentChildObjectMap.size() > 0) {   
            reparentChildObjectMap.put('Materials_Request__c',updMRLastMergerdDateTime(reparentChildObjectMap)); 
        }
        if(reparentChildObjectMap2 != Null && reparentChildObjectMap2.size() > 0) {
            reparentChildObjectMap2.put('Materials_Request__c',updMRLastMergerdDateTime(reparentChildObjectMap2));
        }
        
        system.debug('::::::::::reparentChildObjectMap::::2::'+reparentChildObjectMap);
        system.debug('::::::::::reparentChildObjectMap2::::2::'+reparentChildObjectMap2);
        system.debug('::::::objApiNameAndReparentableBooleanMap:::::::'+objApiNameAndReparentableBooleanMap);
        
        // Updating survivor with new values ---
        
        if((finalSurvivor != null && finalDestroyer != null) || finalDestroyer2 != null){
             
             integer r;
             for(r = 0; r < GeneralInfoList.size();r++) {
                if(GeneralInfoList[r].objFieldName != '' && GeneralInfoList[r].objFieldName != 'AAA'){
                    
                    String fieldname = GeneralInfoList[r].objFieldName;
                    String fieldvalue = GeneralInfoList[r].SelectedValue;
                                       
                    if( FieldNameAndTypeMap.containsKey(fieldname) && FieldNameAndTypeMap.get(fieldname) != NULL) {
                        if(fieldvalue != NULL && fieldvalue != ''){
                            if(FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Boolean')){
                                finalSurvivor.put(fieldname,Boolean.valueOf(fieldvalue));
                            }else if(FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Double') || FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Currency') || FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Percent')){
                                finalSurvivor.put(fieldname,Double.valueOf(fieldvalue));
                            }else if(FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Integer') ){
                                finalSurvivor.put(fieldname,Integer.valueOf(fieldvalue));
                            }else if(FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('Date') ){
                                finalSurvivor.put(fieldname,Date.valueOf(fieldvalue));
                            }else if(FieldNameAndTypeMap.get(fieldname).equalsIgnoreCase('datetime') ){
                                finalSurvivor.put(fieldname,DateTime.valueOfGmt(fieldvalue));
                            }else{
                            //    system.debug('::::type::'+FieldNameAndTypeMap.get(fieldname));
                                finalSurvivor.put(fieldname,fieldvalue);
                            }
                        }else{
                            finalSurvivor.put(fieldname,NULL);
                        }
                    }
                }   
             }
             system.debug(':::finalsurvivor::2::'+finalsurvivor);
             // Reparenting child records -----
            
             List<sObject> toUpdateChidList = new List<sObject>();
             
             system.debug('::::::::::objApiNameAndReparentableBooleanMap:::'+objApiNameAndReparentableBooleanMap);
             
             for(String objnames : reparentChildObjectMap.keyset()){
                if(objApiNameAndReparentableBooleanMap.containsKey(objnames)){
                    if(objApiNameAndReparentableBooleanMap.get(objnames) == true) {
                        system.debug(':::child::::'+reparentChildObjectMap.get(objnames));
                        if(objnames != 'Note' && objnames != 'Attachment'){
                            for(sObject childobj : reparentChildObjectMap.get(objnames)){
                                if(ChildObjNameAndRelatedFieldMap.containsKey(objnames)&& ChildObjNameAndRelatedFieldMap.get(objnames) != NULL) {
                                    Id tempSurvivorId = String.valueOf(finalSurvivor.get('Id'));
                                    childobj.put(ChildObjNameAndRelatedFieldMap.get(objnames),tempSurvivorId);
                                    toUpdateChidList.add(childobj);
                                }
                            }
                        }
                    }
                }
             }
             
             system.debug(':::::toUpdateChidList::::'+toUpdateChidList);
             
             if (reparentChildObjectMap2 != null && reparentChildObjectMap2.size() > 0) {
                 for(String objnames : reparentChildObjectMap2.keyset()){
                    if(objApiNameAndReparentableBooleanMap.containsKey(objnames)){
                        if(objApiNameAndReparentableBooleanMap.get(objnames) == true) {
                            system.debug(':::child::::'+reparentChildObjectMap2.get(objnames));
                            if(objnames != 'Note' && objnames != 'Attachment'){
                                for(sObject childobj : reparentChildObjectMap2.get(objnames)){
                                    if(ChildObjNameAndRelatedFieldMap.containsKey(objnames)&& ChildObjNameAndRelatedFieldMap.get(objnames) != NULL) {
                                        Id tempSurvivorId = String.valueOf(finalSurvivor.get('Id'));
                                        childobj.put(ChildObjNameAndRelatedFieldMap.get(objnames),tempSurvivorId);
                                        toUpdateChidList.add(childobj);
                                    }
                                }
                            }
                        }
                    }
                 }
             }
             
             system.debug(':::::toUpdateChidList::::'+toUpdateChidList);
             
             // Reparent Notes and Attachment ----
                          
             Set<Id> noteidset = new Set<Id>();
             List<Note> notelist = new List<Note>();
             Set<Id> attachmentidset = new Set<Id>();
             List<Attachment> attachmentlist = new List<Attachment>();

             if(enableactivity == true){
                //system.debug('::::Reparent:::'+reparentChildObjectMap);
                if(reparentChildObjectMap.containsKey('Note') && reparentChildObjectMap.get('Note') != NULL) {
                    for(sObject childobj : reparentChildObjectMap.get('Note')){
                        noteidset.add(String.valueOf(childobj.get('Id')));
                    }
                }
                if(reparentChildObjectMap.containsKey('Attachment') && reparentChildObjectMap.get('Attachment') != NULL) {
                    for(sObject childobj : reparentChildObjectMap.get('Attachment')){
                        attachmentidset.add(String.valueOf(childobj.get('Id')));
                    }
                }
                if(destroyerId2 != null && destroyerId2 != '' && reparentChildObjectMap2.containsKey('Note') && reparentChildObjectMap2.get('Note') != NULL) {
                    for(sObject childobj : reparentChildObjectMap2.get('Note')){
                        noteidset.add(String.valueOf(childobj.get('Id')));
                    }
                }
                if(destroyerId2 != null && destroyerId2 != '' && reparentChildObjectMap2.containsKey('Attachment') && reparentChildObjectMap2.get('Attachment') != NULL) {
                    for(sObject childobj : reparentChildObjectMap2.get('Attachment')){
                        attachmentidset.add(String.valueOf(childobj.get('Id')));
                    }
                }
                if(noteidset.size() > 0){
                    for(Note noteobj : [SELECT Id,Title,ParentId,OwnerId,IsPrivate,IsDeleted,Body FROM Note
                                        WHERE Id IN:noteidset]){
                        Note newnote = new Note();
                        newnote = noteobj.Clone(false);
                        newnote.ParentId = String.valueOf(finalSurvivor.get('Id'));
                        notelist.add(newnote);
                    }
                } 

                try{
                    if(notelist != NULL && notelist.size() > 0 ){
                        insert notelist;
                    }
                 }catch(Exception e){
               //     system.debug('::note error:::'+e.getMessage());
                 }
                if(notelist != NULL && notelist.size() > 0 ){
                    notelist.clear();
                }
                if(attachmentidset.size() > 0){
                    for(Attachment attach : [SELECT Id,Body,BodyLength,
                                             ContentType,Description,IsPrivate,Name,OwnerId,ParentId FROM Attachment 
                                             WHERE Id IN:attachmentidset]){
                        Attachment newattachment = new Attachment();
                        newattachment = attach.Clone(false);
                        newattachment.ParentId = String.valueOf(finalSurvivor.get('Id'));
                        attachmentlist.add(newattachment);
                    }
                }
                
             }
            
             try{
                if(attachmentlist != NULL && attachmentlist.size() > 0 ){
                    insert attachmentlist;
                }
             }catch(Exception e){
           //     system.debug('::attachment error:::'+e.getMessage());
             }
             if(attachmentlist != NULL && attachmentlist.size() > 0 ){
                attachmentlist.clear();
             } 
                        
           //  try{
               
               system.debug('::::::toUpdateChidList:::::::'+toUpdateChidList);
               
                if(toUpdateChidList != NULL && toUpdateChidList.size() > 0){
                    //update toUpdateChidList;
                    
                    List<Database.SaveResult> results = Database.Update(toUpdateChidList, false);
                    System.debug(':::results:::'+results);
                    if(results != null && results.size() > 0) {
                        errorRecordId.clear();
                          for(Integer i = 0; i < results.size(); i++) {  
                            
                            if (!results.get(i).isSuccess()){
                                toUpdateChidList.get(i);
                                errorRecordId.add(toUpdateChidList.get(i).Id); 
                             }              
                        }        
 
 
                    }
                    if(errorRecordId != Null && errorRecordId.size() > 0) {
                        errorRecordIdNameMap.clear();
                        for(Materials_Request__c matReq : [SELECT Id, Name FROM Materials_Request__c WHERE Id IN :errorRecordId]) {
                            errorRecordIdNameMap.put(matReq.Id, matReq.Name);        
                        }
                    }
                   
                }
               
               // Exception is not required, error records are stored on map
          /*   }catch(DMLException e){  
                 error = true;
                 ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,e.getMessage()));
             } */
             
             if(errorRecordIdNameMap.size() == 0) {
 
                 try{
                    update finalSurvivor;
                 }catch(Exception e){
                     error = true;
                     ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,e.getMessage()));
                 }
                 
                 try{
                    delete finalDestroyer;
                    if (destroyerId2 != null && destroyerId2 != '') {
                        delete finalDestroyer2;
                    }
                 }catch(Exception e){
                     error = true;
                     ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,e.getMessage()));
                 }
            } else {
                error = true;
                String errMsg = 'Required Fields are Missing on these Material Request Records : ' ;
                for(String recId : errorRecordIdNameMap.keyset()) {
                   // errMsg += errorRecordIdNameMap.get(recId)+',';
                    errMsg += '<a href="/'+recId+'" target="_blank">'+errorRecordIdNameMap.get(recId)+'</a>,';
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,errMsg.removeEnd(',')));       
            }
        }
         
        Id finalsurvivorId = String.valueOf(finalSurvivor.get('Id'));
        if(finalsurvivorId != NULL && error != true){
            PageReference pageref = new PageReference('/'+finalsurvivorId);
            return pageref;
        }
        return null;
     }
     
     public pageReference cancel(){
        
        //PageReference pageref = new PageReference('/apex/SearchRecordsToMerge?RecordOneId='+survivorId );
        //return pageref;
        //return new ApexPages.Action('{!List}').invoke();
         return listView(Materials__c.sObjectType);  
     }
    public static PageReference listView(Schema.sObjectType destinationSObject) {
        Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();
        PageReference pageRef = new PageReference('/' + destination.getKeyPrefix() );
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // Method to update the Last_Material_Merged_DateTime__c field on Material Request 
    
    public static List<sObject> updMRLastMergerdDateTime(Map<String,List<sObject>> updateReparentChildMap) {
       
        List<sObject> matReqReParentRecord = new List<sObject>();
        List<sObject> matReqReParentRecordUpdate = new List<sObject>();
        
        for(String SObj : updateReparentChildMap.keySet()) {
            if(SObj == 'Materials_Request__c') {
                matReqReParentRecord.addAll(updateReparentChildMap.get(SObj));
            }
        }
        SObject Sobj;
        for(sObject rec : matReqReParentRecord) {
            Materials_Request__c mr = (Materials_Request__c)rec;
            mr.Last_Material_Merged_DateTime__c = System.Now().addSeconds(10);  
            
            Sobj = (SObject)mr;
            matReqReParentRecordUpdate.add(Sobj); 
        }
        
        //update matReqReParentRecordUpdate;
        
        system.debug('::::::::matReqReParentRecordUpdate::::::'+matReqReParentRecordUpdate);
        
        // Added to handle the 'entity is deleted' error
        
        List<sObject> matReqReParentRecordFinal = new List<sObject>();
        List<Database.SaveResult> results = Database.Update(matReqReParentRecordUpdate, false);
        system.debug(':::::results:::::'+results);
        if(results != null && results.size() > 0) {     
            for(Integer i = 0; i < results.size(); i++) {       
                if (results.get(i).isSuccess()){
                    system.debug(':::::::matReqReParentRecordUpdate:::::::::::'+matReqReParentRecordUpdate.get(i));
                    matReqReParentRecordFinal.add(matReqReParentRecordUpdate.get(i)); 
                }              
            }        
        }  
        
        system.debug('::::::::::::matReqReParentRecordFinal:::::'+matReqReParentRecordFinal);
        
        return matReqReParentRecordFinal;
    }
     
}