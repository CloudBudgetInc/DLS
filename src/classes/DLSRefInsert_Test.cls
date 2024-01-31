@isTest
private class DLSRefInsert_Test {
    
    @testsetup static void setup() {
        List<PriceBook2> pb = TestClassUtil.createTestPriceBook2();
        List<Opportunity> opp = TestClassUtil.createTestOpportunities();
        Test.startTest();
            Campaign campaignRec = new Campaign(Name = 'Campaign - Child - Advertising - Google/YouTube Ads', Status = 'In Progress', StartDate = Date.Today(), EndDate = Date.Today().addDays(30));
            insert campaignRec;
        Test.stopTest();
    }
    
    // For populating opportunity DLS_Class__c and ContractId field value
    private static testMethod void testMethod1() {
            
        List<Contract> contrList = OppContract('Contract');
        
        if(contrList.size() > 0) {
            List<System_Values__c> sysValuesList = new List<System_Values__c> {
                new System_Values__c(Name = 'DLI-W TO Opportunity ContractID', Value__c = contrList[0].Id),
                new System_Values__c(Name = 'QB Contract - FED/STATE GSA', Value__c = contrList[1].Name)
            };
            insert sysValuesList;
        }
        
        List<Opportunity> oppList = OppContract('Opportunity');
        
        if(oppList.size() > 0) {
            Set<Id> oppIds = new Set<Id>();
            oppIds.add(oppList[0].Id);
            oppIds.add(oppList[1].Id);
            oppIds.add(oppList[2].Id);
            
            if(oppIds.size() > 0) {
                List<Opportunity> oppListUp = [SELECT Id, Name, DLS_Class__c, ContractId, RecordType.DeveloperName FROM Opportunity WHERE Id IN :oppIds];
                Integer Year = Date.Today().Year();

                if(oppListUp.size() > 0) {
                    for(Opportunity opp : oppListUp) {
                        if(opp.RecordType.DeveloperName == 'DLI_W_TO_Opportunities')
                            System.assertEquals(contrList[0].Id, opp.ContractId);
                        else if(opp.RecordType.DeveloperName == 'Admin_Opportunities')
                            System.assert(opp.DLS_Class__c.contains(String.valueof(Year).substring(2,4)));
                    }
                }
            }
        }
    }
    
    // For populating opportunity Default_Cost_Rate_Rate_Type__c field value
    private static testMethod void testMethod2() {
        
        List<Opportunity> oppList = OppContract('Opportunity');
        
        if(oppList.size() > 0) {
            Id dli_W_To_RT;
            
            if( TestClassUtil.rtMap != null && TestClassUtil.rtMap.containskey('Opportunity')) {
                dli_W_To_RT = TestClassUtil.rtMap.get('Opportunity').containskey('DLI_W_TO_Opportunities') ? TestClassUtil.rtMap.get('Opportunity').get('DLI_W_TO_Opportunities') : null;
            } else {
                List<RecordType> oppRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLI_W_TO_Opportunities' AND SobjectType = 'Opportunity'];
                dli_W_To_RT = (oppRT != null && oppRt.size() > 0 ) ? oppRt[0].Id : null;
            }
            if( dli_W_To_RT != null ) {
                oppList[0].Project_Type__c = 'CD';
                oppList[0].RecordTypeId = dli_W_To_RT;
                oppList[1].Project_Type__c = 'MTT';
                oppList[1].RecordTypeId = dli_W_To_RT;
                oppList[2].Project_Type__c = 'Resident LT';
                oppList[2].RecordTypeId = dli_W_To_RT;
                update oppList;
            
                List<Opportunity> oppListUp = [SELECT Id, Name, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[1].Id];
                if(oppListUp.size() > 0) 
                    System.assertEquals('DLI-21 SCA MTT',oppListUp[0].Default_Cost_Rate_Rate_Type__c);
            }
        }
    }
    
    // For populating opportunity QB_Contract_Type__c and A_R_Type__c field value - Opportunity without pricebook
    private static testMethod void testMethod3() {
        
        List<Opportunity> oppList = OppContract('Opportunity');
        if(oppList.size() > 0) {
            
            Id acc_RT_Id;
            
            if( TestClassUtil.rtMap != null && TestClassUtil.rtMap.containskey('Account')) {
                acc_RT_Id = TestClassUtil.rtMap.get('Account').containskey('Commercial_Clients') ? TestClassUtil.rtMap.get('Account').get('Commercial_Clients') : null;
            } else {
                List<RecordType> accRt = [SELECT Id, Name FROM Recordtype WHERE DeveloperName = 'Commercial_Clients' AND SobjectType = 'Account'];
                acc_RT_Id = (accRt != null && accRt.size() > 0 ) ? accRt[0].Id : null;
            }
            if( acc_RT_Id != null ) {
                List<Account> accList = new List<Account> {
                    new Account(Name = 'PVT'),
                    new Account(Name = 'Test Acc', RecordTypeId = acc_RT_Id)
                };
                insert accList;
    
                List<System_Values__c> sysValuesList = new List<System_Values__c> {
                    new System_Values__c(Name = 'Opp QB type - COMM:INDV Acct', Value__c = 'PVT')
                };
                insert sysValuesList;
                
                oppList[0].QB_Contract_Type__c = null;
                oppList[0].AccountId = accList[0].Id;
                oppList[1].QB_Contract_Type__c = null;
                oppList[1].AccountId = accList[1].Id;
                update oppList;
                
                List<Opportunity> oppListUp = [SELECT Id, Name, QB_Contract_Type__c, A_R_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
                if(oppListUp.size() > 0) {
                    System.assertEquals('COMM:INDV', oppListUp[0].QB_Contract_Type__c);
                    System.assertEquals('11005-Prepayment', oppListUp[0].A_R_Type__c);
                }
            }
        }
    }
    
    // For populating opportunity QB_Contract_Type__c field value - Opportunity with pricebook
    private static testMethod void testMethod4() {
    
        List<Opportunity> oppList = OppContract('Opportunity');
        List<PriceBook2> pbList = [SELECT Id, Name FROM PriceBook2 WHERE Name IN ('GSA Language Training Price Book', 'PriceBook1')];
        
        if(oppList.size() > 0 && pbList.size() > 0) {
            
            /*List<PriceBook2> pbList = new List<PriceBook2> {
                                      new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True),
                                      new PriceBook2(Name = 'PriceBook1', IsActive = True)
                                  };
            insert pbList;*/
            //List<RecordType> accRt = [SELECT Id, Name FROM Recordtype WHERE DeveloperName = 'Accounts' AND SobjectType = 'Account'];
            
            Id acc_RT_Id;
            
            if( TestClassUtil.rtMap != null && TestClassUtil.rtMap.containskey('Account')) {
                acc_RT_Id = TestClassUtil.rtMap.get('Account').containskey('Accounts') ? TestClassUtil.rtMap.get('Account').get('Accounts') : null;
            } else {
                List<RecordType> accRt = [SELECT Id, Name FROM Recordtype WHERE DeveloperName = 'Accounts' AND SobjectType = 'Account'];
                acc_RT_Id = (accRt != null && accRt.size() > 0 ) ? accRt[0].Id : null;
            }
            if( acc_RT_Id != null ) {
                List<Account> accList = new List<Account> {
                    new Account(Name = 'Account', RecordTypeId = acc_RT_Id)
                };
                insert accList;
                    
                oppList[0].Pricebook2Id = pbList[0].Id;
                oppList[0].QB_Contract_Type__c = null;
                oppList[0].AccountId = accList[0].Id;
                oppList[1].Pricebook2Id = pbList[1].Id;
                oppList[1].QB_Contract_Type__c = null;
                oppList[1].AccountId = accList[0].Id;
                update oppList;
                
                List<Opportunity> oppListUp = [SELECT Id, Name, QB_Contract_Type__c, A_R_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
                if(oppListUp.size() > 0) 
                    System.assertEquals('FED:GSA', oppListUp[0].QB_Contract_Type__c);
            }
        }
    }
    
    // For populating opportunity GSA_Min_Experience__c/GSA_Min_Education__c/Min_Experience__c/Min_Education__c field value - Opportunity with pricebook
    private static testMethod void testMethod5() {
    
        List<Opportunity> oppList = OppContract('Opportunity');
        List<PriceBook2> pbList = [SELECT Id, Name, Min_Education__c, Min_Experience__c FROM PriceBook2 WHERE Name IN ('GSA Language Training Price Book', 'GSA Translation Price Book')];
        
        if(oppList.size() > 0 && pbList.size() > 0) {
            
            /*List<PriceBook2> pbList = new List<PriceBook2> {
                                      new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True, Min_Education__c = 'Test Min edu 1', Min_Experience__c = 'TWO'),
                                      new PriceBook2(Name = 'GSA Translation Price Book', IsActive = True, Min_Education__c = 'Test Min edu 2', Min_Experience__c = 'ONE')
                                  };
            insert pbList;*/
            //List<RecordType> accRt = [SELECT Id, Name FROM Recordtype WHERE DeveloperName = 'Accounts' AND SobjectType = 'Account'];
            Id acc_RT_Id;
            
            if( TestClassUtil.rtMap != null && TestClassUtil.rtMap.containskey('Account')) {
                acc_RT_Id = TestClassUtil.rtMap.get('Account').containskey('Accounts') ? TestClassUtil.rtMap.get('Account').get('Accounts') : null;
            } else {
                List<RecordType> accRt = [SELECT Id, Name FROM Recordtype WHERE DeveloperName = 'Accounts' AND SobjectType = 'Account'];
                acc_RT_Id = (accRt != null && accRt.size() > 0 ) ? accRt[0].Id : null;
            }
            
            if( acc_RT_Id != null ) {
                List<Account> accList = new List<Account> {
                    new Account(Name = 'Account', RecordTypeId = acc_RT_Id)
                };
                insert accList;
                    
                oppList[0].Pricebook2Id = pbList[0].Id;
                oppList[1].Pricebook2Id = pbList[1].Id;
                update oppList;
                
                List<Opportunity> oppListUp = [SELECT Id, Name, GSA_Min_Education__c, A_R_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
                if(oppListUp.size() > 0) 
                    System.assertEquals(pbList[0].Min_Education__c, oppListUp[0].GSA_Min_Education__c);
            }
        }
    } 
    
    // For populating default values for the fields on creating the Opportunity with DODA record type
    private static testMethod void testMethod6() {
        
        List<Sobject_Master_Field_Mapping__c> sobjFieldMappingList = new List<Sobject_Master_Field_Mapping__c> {
            new Sobject_Master_Field_Mapping__c(Name = 'Test FieldMapping 1', Object_Name__c = 'Opportunity', RecordType_Name__c = 'ODNI_CLP_Opportunities', Field_Name__c = 'StageName', Default_Field_Value__c = 'Active'),
            new Sobject_Master_Field_Mapping__c(Name = 'Test FieldMapping 2', Object_Name__c = 'Opportunity', RecordType_Name__c = 'ODNI_CLP_Opportunities', Field_Name__c = 'CloseDate', Default_Field_Value__c = String.valueOf(System.today()))
        };
        insert sobjFieldMappingList;
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration')];
        List<Contract> contrList = OppContract('Contract');
        List<Contract> contractList = [SELECT Id, Name, ContractNumber FROM Contract LIMIT 2];
        
        if(contractList.size() > 0 && rType.size() > 0) {
            
            Id oppRtId, proRtId;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities')
                    oppRtId = rt.Id;
                else if(rt.DeveloperName == 'SLP_Iteration')
                    proRtId = rt.Id;
            }
            
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :contrList[0].AccountId];
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proRtId, Midterm_Progress_Due_Date__c = Date.Today().addDays(30), Final_Progress_Due_Date__c = Date.Today().addDays(90))
            };
            insert proItrList;
            
            if(accList.size() > 0) {
            
                List<System_Values__c> sysValuesList = new List<System_Values__c> {
                    new System_Values__c(Name = 'QB Contract - FED/STATE GSA', Value__c = contractList[0].Name),
                    new System_Values__c(Name = 'ELT III Account - Contract', Value__c = contractList[1].ContractNumber),
                    new System_Values__c(Name = 'ELT III AccountId', Value__c = accList[0].Name)
                };
                insert sysValuesList;
            }
            
            List<Opportunity> oppList = new List<Opportunity> {
                new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry', Program_Iteration__c = proItrList[0].Id, End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id,RecordTypeId = oppRtId),
                new Opportunity(Name = 'Test Opp 2',StageName = 'Active', Program_Iteration__c = proItrList[0].Id, Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = accList[0].Id,RecordTypeId = oppRtId)
            };
            insert oppList;
            
            List<Opportunity> oppListRet = [SELECT Id, Name, Start_Date__c FROM Opportunity WHERE Id = :oppList[0].Id];
            if(oppListRet.size() > 0)
                System.assertEquals(oppListRet[0].Start_Date__c, proItrList[0].Start_Date__c);
        }
    } 
    
    /*private static testMethod void testMethod7() {
        
        List<RecordType> oppRt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'New_Classes_Opportunities'];
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        List<Contract> contractList = [SELECT Id, Name, ContractNumber FROM Contract LIMIT 2];
        
        if(oppRt.size() > 0 && accList.size() > 0 && contractList.size() > 0) {
            
            List<System_Values__c> sysValuesList = new List<System_Values__c> {
                new System_Values__c(Name = 'ELT III Account - Contract', Value__c = contractList[0].ContractNumber),
                new System_Values__c(Name = 'ELT III AccountId', Value__c = accList[0].Name)
            };
            insert sysValuesList;
            System.debug(':::***:::oppRt:::'+oppRt[0].Id);
            List<Opportunity> oppList = new List<Opportunity> {
                new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry', End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id,RecordTypeId = oppRt[0].Id),
                new Opportunity(Name = 'Test Opp 2',StageName = 'Active', Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = accList[0].Id,RecordTypeId = oppRt[0].Id)
            };
            insert oppList;
            
            List<Opportunity> oppUp = [SELECT Id, Name, ContractId FROM Opportunity LIMIT 1];
            if(oppUp.size() > 0)
                System.assertEquals(contractList[0].Id, oppUp[0].ContractId);
        }
    }*/
    
    // Based on the parameter Opportunity/Contarct records will be inserted   
    private static List<Sobject> OppContract(String obj) { 
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        
        if(accList.size() > 0) {
            if(obj == 'Opportunity') {
                List<RecordType> oppRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName IN ('DLI_W_TO_Opportunities', 'Admin_Opportunities', 'Testing_Opportunities') AND SobjectType = 'Opportunity'];
                
                List<Opportunity> oppList = new List<Opportunity>();
                
                if(oppRt.size() > 0) {     
                    oppList = new List<Opportunity> {
                        new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id,RecordTypeId = oppRt[0].Id),
                        new Opportunity(Name = 'Test Opp 2',StageName = 'Active',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = accList[1].Id,RecordTypeId = oppRt[1].Id),
                        new Opportunity(Name = 'Test Opp 2',StageName = 'Active',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = accList[1].Id,RecordTypeId = oppRt[2].Id)
                    };
                    insert oppList;
                }
                return oppList;
            } else if(obj == 'Contract') {
                
                List<RecordType> contractRt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contract' LIMIT 2];
                
                List<Contract> contractList = new List<Contract>();
                if(contractRt.size() > 0) {
                    List<Contact> conList = new List<Contact> {
                            new Contact(LastName = 'Test Con1', Email = 'Test1@gmail.com'),
                            new Contact(LastName = 'Test Con2', Email = 'Test2@gmail.com')
                        };
                        insert conList;
                        
                    contractList = new List<Contract> {
                        new Contract(Name = 'Test Contract 1', RecordTypeId = contractRt[0].Id, AccountId = accList[0].Id, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(5), Primary_POC__c = conList[0].Id),
                        new Contract(Name = 'Test Contract 2', RecordTypeId = contractRt[1].Id, AccountId = accList[1].Id, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(6), Primary_POC__c = conList[1].Id)
                    };
                    insert contractList;
                }
                return contractList;
            }
        }
        return null;
    }
    
    private static testMethod void populateCampaignId1() {
        
        Campaign campaignRec = [SELECT Id, Name FROM Campaign WHERE Name = 'Campaign - Child - Advertising - Google/YouTube Ads' LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id, GCLID__c FROM Opportunity LIMIT 1];
        oppRec[0].GCLID__c = 'Test Google link value';
        update oppRec[0];
        
        Test.startTest();
            List<Opportunity> oppRec1 = [SELECT Id, CampaignId, GCLID__c FROM Opportunity WHERE Id = :oppRec[0].Id];
            System.assertEquals(campaignRec.Id, oppRec1[0].CampaignId);
        Test.stopTest();
    }
    
    private static testMethod void populateCampaignId2() {
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Campaign campaignRec = [SELECT Id, Name FROM Campaign WHERE Name = 'Campaign - Child - Advertising - Google/YouTube Ads' LIMIT 1];
        
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', GCLID__c = 'Test Google link value', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id);
        insert opp;
        
        Test.startTest();
            List<Opportunity> oppRec = [SELECT Id, CampaignId, GCLID__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(campaignRec.Id, oppRec[0].CampaignId);
        Test.stopTest();
    }
    
    private static testMethod void updateDLSClassNum_TestOpp() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id newClassRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        Id testingRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
            
        Opportunity opp = new Opportunity(RecordTypeId = newClassRT_Id, Name = 'DLSClass Testing Opp 1', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id);
        insert opp;
        
        List<Opportunity> oppRec = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id  = :opp.Id];
        oppRec[0].RecordTypeId = testingRT_Id;
        update oppRec[0];
        
        Test.startTest();
            List<Opportunity> updated_OppRec = [SELECT Id, DLS_Class__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(null, oppRec[0].DLS_Class__c);
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_1() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id cd_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CD_Opportunities').getRecordTypeId();
        Id efl_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('EFL_Opportunities').getRecordTypeId();
        Id ip_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Interpretation_Opportunities').getRecordTypeId();
        Id mtt_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTT_Opportunities').getRecordTypeId();
        Id doda_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();
                
        List<Opportunity> oppList = new List<Opportunity>{
        
            new Opportunity(RecordTypeId = cd_RT_Id, Name = 'Flow Test CD Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id),
            new Opportunity(RecordTypeId = efl_RT_Id, Name = 'Flow Test EFL Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id),
            new Opportunity(RecordTypeId = ip_RT_Id, Name = 'Flow Test IP Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id),
            new Opportunity(RecordTypeId = mtt_RT_Id, Name = 'Flow Test MTT Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id),
            new Opportunity(Classification__c = 'OF0MTT0PS', RecordTypeId = doda_RT_Id, Name = 'Flow Test DODA Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> updated_OppRec = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE RecordTypeId = :doda_RT_Id];
            System.assertEquals('DODA PS', updated_OppRec[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_2() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id dli_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
                
        List<Opportunity> oppList = new List<Opportunity>{
        
            new Opportunity(DLI_Project_Type__c = 'Partner School', RecordTypeId = dli_RT_Id, Name = 'Flow Test DLI-W Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id),
            new Opportunity(Enrollment_Date__c = Date.Today().addDays(10), DLI_Project_Type__c = 'EI', RecordTypeId = dli_RT_Id, Name = 'Flow Test DLI-W Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> updated_OppRec = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE DLI_Project_Type__c = 'EI'];
            updated_OppRec[0].Project_Type__c = 'CD';
            update updated_OppRec[0];
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :updated_OppRec[0].Id];
            System.assertEquals('DLI-21 SCA CD', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_3() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id fsi_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FSI_Opportunities').getRecordTypeId();
                
        List<Opportunity> oppList = new List<Opportunity>{
        
            new Opportunity(Default_Cost_Rate_Rate_Type__c = 'LT with Billable Prep', RecordTypeId = fsi_RT_Id, Name = 'New Test FSI Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('FSI', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_4() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id newClass_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
                
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(RecordTypeId = newClass_RT_Id, Name = 'New Class Test Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('LT without Billable Prep', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_5() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id doda_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();        
        Id slp_RT_Id = Schema.SObjectType.Program_Iteration__c.getRecordTypeInfosByDeveloperName().get('SLP_Iteration').getRecordTypeId();
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI Test', Project_Type__c = 'SLP-PT', Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = slp_RT_Id, Midterm_Progress_Due_Date__c = Date.Today().addDays(30), Final_Progress_Due_Date__c = Date.Today().addDays(90))
        };
        insert proItrList;
            
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(Program_Iteration__c = proItrList[0].Id, RecordTypeId = doda_RT_Id, Name = 'New Class Test Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('LT with Billable Prep', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_6() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id doda_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();        
        Id slp_RT_Id = Schema.SObjectType.Program_Iteration__c.getRecordTypeInfosByDeveloperName().get('SLP_Iteration').getRecordTypeId();
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI Test', Project_Type__c = 'JMAS', Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = slp_RT_Id, Midterm_Progress_Due_Date__c = Date.Today().addDays(30), Final_Progress_Due_Date__c = Date.Today().addDays(90))
        };
        insert proItrList;
            
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(Program_Iteration__c = proItrList[0].Id, RecordTypeId = doda_RT_Id, Name = 'New Class Test Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('LT without Billable Prep', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_7() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id doda_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();        
        
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(RecordTypeId = doda_RT_Id, Name = 'New Class Test Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('LT without Billable Prep', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
        Test.stopTest();
    }
    
    private static testMethod void populateDCRRT_8() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id doda_RT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();        
        Id slp_RT_Id = Schema.SObjectType.Program_Iteration__c.getRecordTypeInfosByDeveloperName().get('SLP_Iteration').getRecordTypeId();
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI Test', Project_Type__c = 'JMAS', Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = slp_RT_Id, Midterm_Progress_Due_Date__c = Date.Today().addDays(30), Final_Progress_Due_Date__c = Date.Today().addDays(90))
        };
        insert proItrList;
            
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(Program_Iteration__c = proItrList[0].Id, RecordTypeId = doda_RT_Id, Name = 'New Class Test Opp', StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = accList[0].Id)
        };
        insert oppList;
        
        Test.startTest();
            
            List<Opportunity> oppREc = [SELECT Id, Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :oppList[0].Id];
            System.assertEquals('LT without Billable Prep', oppREc[0].Default_Cost_Rate_Rate_Type__c);
            
            oppList[0].Classification__c = 'OF0MTT0PS';
            update oppList[0];
        
        Test.stopTest();
    }
}