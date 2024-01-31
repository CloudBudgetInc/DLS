/*******************************************************************************
- class for Upgrade and Downgrade the Lisence based on Project no. of active students for Events with room as 'DLS - Online' with Is Moved Online Via Community field as true
- This will be called from ZoomUserLicenseValidationBatch
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomUserLicenseUpdationBatch implements Database.AllowsCallouts, Database.Batchable<Id>, Database.Stateful{
    public List<Id> instructorsNeedProLicense;
    public List<Id> instructorsNeedBasicLicense;
    public Boolean isForUpgrade;    //Based on the boolean downgrade/upgrade the licenses for the Zoom User
    public List<ErrorHandler.ErrorLogUtilDomain> errorlogs = new List<ErrorHandler.ErrorLogUtilDomain>(); //Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
    
    public ZoomUserLicenseUpdationBatch(List<Id> instructorsNeedProLicense,  List<Id> instructorsNeedBasicLicense, Boolean isForUpgrade){
        
        this.instructorsNeedProLicense = new List<Id>(instructorsNeedProLicense);
        this.instructorsNeedBasicLicense = new List<Id>(instructorsNeedBasicLicense);
        this.isForUpgrade = isForUpgrade;
    }
    
    public List<Id> start(Database.BatchableContext BC){
                     
        return isForUpgrade ? instructorsNeedProLicense : instructorsNeedBasicLicense;
    }
    
    public void execute(Database.BatchableContext BC, List<Id> instructorIds){
                
        for(Contact con : [SELECT Id, FirstName, LastName, Email, Zoom_ID__c, Virtual_Conference_License__c FROM Contact WHERE Id IN :instructorIds AND Active_DLS_Online_User__c = true]){
           try{
               ZoomUtil.getUserDetailsAndUpdateDetails(con.Zoom_ID__c, JSON.serialize(new ZoomDomain.zoomUser(isForUpgrade ? '2' : '1'), true), con.Id, false, true);           
           }catch(Exception exe){
               String result = exe.getMessage();            
               errorlogs.add(new ErrorHandler.ErrorLogUtilDomain('ZoomUserLicenseUpdationBatch','ZoomUserLicenseUpdationBatch','',result+' at line number '+exe.getLineNumber(),JSON.serialize(con),'Batch'));
           }   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        //To upgrade the licenses for the Zoom User
        if(!isForUpgrade){
            System_Values__c sysVal = System_Values__c.getValues('Zoom User License Update Batch size');
            ZoomUserLicenseUpdationBatch bat = new ZoomUserLicenseUpdationBatch(instructorsNeedProLicense, instructorsNeedBasicLicense, true);
            database.executeBatch(bat, Integer.valueOf(sysVal.Value__c));
        }
        //Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
        if(errorlogs.size() > 0){
            try{
                ErrorHandler.publishErrorLog(errorlogs);
            }catch(Exception exe){
                String result = exe.getMessage();
                ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingCreationBatch','ZoomMeetingCreationBatch','',result+' at line number '+exe.getLineNumber(),JSON.serialize(errorlogs),'Batch')});
            } 
        }
    }
}