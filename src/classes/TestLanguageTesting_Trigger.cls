/* Modified By Siva Prasanth on 10/9/2020*/
@isTest
public class TestLanguageTesting_Trigger{
    
    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        List<Skill__c> skillList = TestClassUtil.createTestSkill();
    }
    
    // Language Testing insertion
    private static testMethod void myTest1(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c,S_Goal__c = '0',L_Goal__c='0',R_Goal__c = '0',W_Goal__c = '0',Target_Language__c = 'English'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c,Target_Language__c = 'French', Date_Time_Scheduled__c = System.now())
            };
                
            insert langtestList;
            
            createdLangtestList = [SELECT Id,Testee__c FROM Language_Testing__c LIMIT 1];
            System.assertEquals(true, createdLangtestList.size() > 0);
            System.assertEquals(conAssigns[0].Candidate_Name__c , createdLangtestList[0].Testee__c);
        }
    }
    
    private static testMethod void myTest2(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c,S_Goal__c = '0',L_Goal__c='0',R_Goal__c = '0',W_Goal__c = '0',Target_Language__c = 'Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian')
            };
                
            insert langtestList;
            
            createdLangtestList = [SELECT Id,Testee__c FROM Language_Testing__c LIMIT 1];
            System.assertEquals(true, createdLangtestList.size() > 0);
            System.assertEquals(conAssigns[0].Candidate_Name__c , createdLangtestList[0].Testee__c);
        }
    }
    
    private static testMethod void myTest3(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, L_Goal__c='2', L_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, L_Goal__c='4', L_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian'),
                new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, L_Goal__c='3', L_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian')
            };
            
            Test.startTest();
            
                insert langtestList;      
                
                List<Language_Testing__c> langTest = [SELECT Id, L_Score__c FROM Language_Testing__c WHERE Id IN : langtestList];       
                langTest[0].L_Score__c = '4+';
                update langTest[0];   
                
                List<Language_Testing__c> langTest1 = [SELECT Id, L_Score_vs_Goal__c FROM Language_Testing__c WHERE Id IN : langTest];       
                System.assertEquals('Exceeded goal', langTest1[0].L_Score_vs_Goal__c);
                
            Test.stopTest();    
        }
    }
    
    private static testMethod void myTest4(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, R_Goal__c='2', R_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, R_Goal__c='4', R_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian'),
                new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, R_Goal__c='3', R_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian')
            };
            
            Test.startTest();
            
                insert langtestList;    
                
                List<Language_Testing__c> langTest = [SELECT Id, R_Score__c FROM Language_Testing__c WHERE Id IN : langtestList];       
                langTest[0].R_Score__c = '0';
                update langTest[0];  
                
                List<Language_Testing__c> langTest1 = [SELECT Id, R_Score_vs_Goal__c FROM Language_Testing__c WHERE Id IN : langTest];       
                System.assertEquals('Did not meet goal', langTest1[0].R_Score_vs_Goal__c);
            Test.stopTest();      
        }
    }
    
    private static testMethod void myTest5(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, S_Goal__c='2', S_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, S_Goal__c='4', S_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian'),
                new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, S_Goal__c='3', S_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian')
            };
            
            Test.startTest();
            
                insert langtestList;  
                
                List<Language_Testing__c> langTest = [SELECT Id, S_Score__c FROM Language_Testing__c WHERE Id IN : langtestList];       
                                
                List<Language_Testing__c> langTest1 = [SELECT Id, S_Score_vs_Goal__c FROM Language_Testing__c WHERE Id IN : langTest];       
                System.assertEquals('Exceeded goal', langTest1[0].S_Score_vs_Goal__c);
            Test.stopTest();
        }
    }
    
    private static testMethod void myTest5a(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, W_Goal__c='2', W_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, W_Goal__c='4', W_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian'),
                new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, W_Goal__c='3', W_Score__c = '3', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Russian')
            };
            
            Test.startTest();
            
                insert langtestList;  
                
                List<Language_Testing__c> langTest = [SELECT Id, S_Score__c FROM Language_Testing__c WHERE Id IN : langtestList];       
                                
                List<Language_Testing__c> langTest1 = [SELECT Id, W_Score_vs_Goal__c FROM Language_Testing__c WHERE Id IN : langTest];       
                System.assertEquals('Exceeded goal', langTest1[0].W_Score_vs_Goal__c);
            Test.stopTest();
        }
    }
    
    private static testMethod void myTest6(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        List<Language_Testing__c> createdLangtestList = new List<Language_Testing__c>();

        if(conAssigns.size() > 0){
            
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, L_Goal__c='2', L_Score__c = '2', R_Goal__c='2', R_Score__c = '2', S_Goal__c='2', S_Score__c = '2', Date_Time_Scheduled__c = System.now(),Target_Language__c = 'Tamil')
            };
            
            Test.startTest();
            
                insert langtestList;  
                
            Test.stopTest();
        }
    }
    
    private static testMethod void myTest7(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', L_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Final', L_Score__c='2'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Final', L_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', L_Score__c='3')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id,L_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList2];
            System.assertEquals(-1, langTest[0].L_Initial_vs_Final_Increase__c);
            System.assertEquals(1, langTest[1].L_Initial_vs_Final_Increase__c);
            System.assertEquals(0, langTest[2].L_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest8(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', R_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Final', R_Score__c='2'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Final', R_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', R_Score__c='3')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, R_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList2];
            System.assertEquals(-1, langTest[0].R_Initial_vs_Final_Increase__c);
            System.assertEquals(1, langTest[1].R_Initial_vs_Final_Increase__c);
            System.assertEquals(0, langTest[2].R_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest9(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', S_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Final', S_Score__c='2'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Final', S_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', S_Score__c='3')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, S_Initial_vs_Final_Increase__c, L_Score__c, Project__c,  Testee__c FROM Language_Testing__c WHERE Id IN : langtestList2];
            System.assertEquals(-1, langTest[0].S_Initial_vs_Final_Increase__c);
            System.assertEquals(1, langTest[1].S_Initial_vs_Final_Increase__c);
            System.assertEquals(0, langTest[2].S_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest10(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', W_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Final', W_Score__c='2'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Final', W_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', W_Score__c='3')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, W_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList2];
            System.assertEquals(-1, langTest[0].W_Initial_vs_Final_Increase__c);
            System.assertEquals(1, langTest[1].W_Initial_vs_Final_Increase__c);
            System.assertEquals(0, langTest[2].W_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest11(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', L_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Initial', L_Score__c='2'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Initial', L_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', L_Score__c='3')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id,L_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList1];
            System.assertEquals(0, langTest[0].L_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest12(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', R_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Initial', R_Score__c='3'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Initial', R_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', R_Score__c='2')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, R_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList1];
            System.assertEquals(1, langTest[0].R_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest13(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', S_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Initial', S_Score__c='3'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Initial', S_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', S_Score__c='2')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, S_Initial_vs_Final_Increase__c, L_Score__c, Project__c,  Testee__c FROM Language_Testing__c WHERE Id IN : langtestList1];
            System.assertEquals(1, langTest[0].S_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest14(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Final', W_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Initial', W_Score__c='3'),
                new Language_Testing__c(Name='Test Lang5', Project__c = conAssigns[1].Project__c, Testee__c = conAssigns[1].Candidate_Name__c, Test_Type__c = 'Initial', W_Score__c='4'),
                new Language_Testing__c(Name='Test Lang6', Project__c = conAssigns[2].Project__c, Testee__c = conAssigns[2].Candidate_Name__c, Test_Type__c = 'Initial', W_Score__c='2')
            };
            insert langtestList2;
            
            List<Language_Testing__c> langTest = [SELECT Id, W_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList1];
            System.assertEquals(1, langTest[0].W_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest15(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE Project__c != null];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang3', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Final', W_Score__c='3')
        };
        insert langtestList1;
        
        Test.startTest();
            
            List<Language_Testing__c> langtestList2 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang4', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Test_Type__c = 'Initial', W_Score__c='3+')
            };
            insert langtestList2;
            
            List<Language_Testing__c> initialLTRec = [SELECT Id, W_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList2];
            initialLTRec[0].W_Score__c = '5';
            update initialLTRec[0];
            
            List<Language_Testing__c> finalLtRec = [SELECT Id, W_Initial_vs_Final_Increase__c FROM Language_Testing__c WHERE Id IN : langtestList1];
            System.assertEquals(2, finalLtRec[0].W_Initial_vs_Final_Increase__c);
        Test.stopTest();
    }
}