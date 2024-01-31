/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 07/20/2023
 * @last modified by  : Dhinesh Kumar
**/
public class CongaHelper {
    
    public static Map<String, String> congaTempNameMap = new Map<String, String>{
        'Observation_Report' => 'Observation Report',
        'Test_Report' => 'Test Report',
        'DLI_W_Test_Report' => 'DLI Test Report',
        'DLI_W_Self_Assessment_Test_Report'=> 'DLI Self Assessment Test Report',
        'Annual_Instructor_Performance_Review' => 'Annual Instructor Performance Review',
        'DLI_Observation_Report' => 'DLI Observation Report'
    };
        
    public static Map<String, String> congaEmailTempNameMap = new Map<String, String>{
        'Observation_Report' => 'Observation Report',
        'Test_Report' =>   'Test Report', 
        'DLI_W_Test_Report' => 'DLI 2022 Test Report',
        'DLI_W_Self_Assessment_Test_Report' =>'DLI 2022 Student Self Assessment Test Report',
        'Annual_Instructor_Performance_Review' =>  'Annual Instructor Performance Review',
        'DLI_Observation_Report' => 'Observation Report'     
    };
        
    public static Id getCongaTemplateId(String type){
        Id congaTemplateId;
        String congaTemplateName = congaTempNameMap.get(type);
        for(APXTConga4__Conga_Template__c ct : [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :congaTemplateName]) {
            congaTemplateId = ct.Id;
        }
        
        return congaTemplateId;
    }
    
    public static Id getCongaEmailTemplateId(String type){
        Id emailTemplateId;
        String congaEmailTemp = congaEmailTempNameMap.get(type);
        for(APXTConga4__Conga_Email_Template__c et: [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = :congaEmailTemp]){
            emailTemplateId = et.Id;
        }
        
        return emailTemplateId;
    }
    
    public static Boolean checkIsNew(Assessment_Report__c assessmentReport, Boolean checkForCongaSign){ //, String type
        if(checkForCongaSign){
            List<APXT_CongaSign__Transaction__c> congaTransRec = CongaSignTransactionService.getCongaSignTransactions('Parent_a5E__c = \''+ assessmentReport.Id +'\' AND APXT_CongaSign__Status__c IN (\'COMPLETE\',\'SENT\')', '');
            return congaTransRec.size() < 1;
        }else{
            //type = '%'+type+'%';
            List<EmailMessage> emailMsgs = [SELECT Id, Subject, ToAddress FROM EmailMessage WHERE Status = '3' AND RelatedToId = :assessmentReport.Id]; //AND Subject LIKE :type
            return emailMsgs.size() < 1;
        }
    }
}