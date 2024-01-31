/*******************************************************************************
- class for scheduling Zoom User License Validation batch for Events with room as 'DLS - Online' with Is Moved Online Via Community field as true
- Created by Dhinesh - W-006013 - Zoom Integration
- Scheduled on Daily basis
*******************************************************************************/
public class ZoomUserLicenseValidation_Scheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        System_Values__c sysVal = System_Values__c.getValues('Zoom User Validation Batch size');
        ZoomUserLicenseValidationBatch userLicenseValidationBatch = new ZoomUserLicenseValidationBatch();
        Database.executeBatch(userLicenseValidationBatch, Integer.valueOf(sysVal.Value__c));
    }
}