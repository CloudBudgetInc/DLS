@isTest
public class EmploymentSectionUpdateOppTest {
    
    @testSetup static void setupMethod(){
        //Insert Paper Timesheet custom setting
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
        
        Insert sysVal;
    }
    
    public static testMethod void myTest() {
    
            Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
            Account Acc2 = new Account();
            Acc2.Name = 'Test Account';
            Database.insert(Acc2);
            
            //CASE 2: test an insert/update of a Hanover active class with instructor, employment section = Hanover/Columbia
            Opportunity OppB = new Opportunity();
            OppB.StageName = 'Active';
            OppB.Offsite_Location__c = 'Hanover';
            OppB.Name = 'UtestB';
            OppB.AccountId = Acc2.Id;
            OppB.Supervisor__c = userInfo.getUserId();
            OppB.CloseDate = Date.today();
            OppB.Start_Date__c = system.today();
            Contact InstructorB = new Contact();
            InstructorB.LastName = 'UtestB';
            InstructorB.Employment_Section__c = null;
            InstructorB.Next_Availability__c = null;
            InstructorB.Instructor_Status__c = 'Available';
            InstructorB.Current_Account__c = null;
            InstructorB.RecordTypeId=rt.id;
            Database.insert(InstructorB);
            OppB.InstructorName__c = InstructorB.Id;
            Database.insert(OppB);
            Database.update(InstructorB);
        }
        
        public static testMethod void myTest1(){
            
            Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
            Account Acc2 = new Account();
            Acc2.Name = 'Test Account';
            Database.insert(Acc2);
            
             //CASE 11: test update and AFPAK class
            Contact InstructorD = new Contact();
            InstructorD.LastName = 'UtestD';
            InstructorD.Employment_Section__c = null;
            InstructorD.Next_Availability__c = null;
            InstructorD.Instructor_Status__c ='Available';
            InstructorD.Current_Account__c = null;
            InstructorD.RecordTypeId=rt.id;
            Database.insert(InstructorD);
            Opportunity OppD = new Opportunity();
            OppD.AccountId = Acc2.Id;
            OppD.StageName = 'Active';
            OppD.Offsite_Location__c = 'Arlington';
            OppD.Name = 'UtestD';
            OppD.CloseDate = Date.today();
            OppD.Start_Date__c = system.today();
            OppD.InstructorName__c = InstructorD.Id;
            oppd.Supervisor__c = userInfo.getUserId();
            Database.insert(OppD);
            OppD.Name='test12';
            OppD.Section__c='AFPAK';
            Database.update(OppD);
            //Database.update(InstructorD);
            
            Contact InstructorB = new Contact();
            InstructorB.LastName = 'UtestB';
            InstructorB.Employment_Section__c = null;
            InstructorB.Next_Availability__c = null;
            InstructorB.Instructor_Status__c = 'Available';
            InstructorB.Current_Account__c = null;
            InstructorB.RecordTypeId=rt.id;
            Database.insert(InstructorB);
            
            OppD.InstructorName__c = InstructorB.Id;
            //Database.update(OppD);
            //Database.update(InstructorD);
            //Database.update(InstructorB);
            
        }
        
        public static testMethod void myTest2(){
            
            Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
            Account Acc2 = new Account();
            Acc2.Name = 'Test Account';
            Database.insert(Acc2);
            
            //CASE 10: Test update and RA class
            Contact InstructorE = new Contact();
            InstructorE.LastName = 'UtestE';
            InstructorE.Employment_Section__c = null;
            InstructorE.Next_Availability__c = null;
            InstructorE.Instructor_Status__c = 'Available';
            InstructorE.Current_Account__c = null;
            InstructorE.RecordTypeId=rt.id;
            Database.insert(InstructorE);
            Opportunity OppE = new Opportunity();
            OppE.AccountId = Acc2.Id;
            OppE.StageName = 'Active';
            OppE.Offsite_Location__c = 'Hanover';
            OppE.Name = 'UtestE';
            OppE.Section__c='RA';
            OppE.CloseDate = Date.today();
            oppe.Supervisor__c = userInfo.getUserId();
            OppE.InstructorName__c = InstructorE.Id;
            OppE.Start_Date__c = system.today();
            Database.insert(OppE);
            OppE.Name='test14';
            OppE.Offsite_Location__c = 'Arlington';
            Database.update(OppE);
            Database.update(InstructorE);  
            
        }
        
        public static testMethod void myTest3(){
            
            Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
            Account Acc2 = new Account();
            Acc2.Name = 'Test Account';
            Database.insert(Acc2);
            
            //CASE 9: test update and state Active, section EE, Arlington 
            Contact InstructorF = new Contact();
            InstructorF.LastName = 'UtestF';
            InstructorF.Employment_Section__c = null;
            InstructorF.Next_Availability__c = null;
            InstructorF.Instructor_Status__c = 'Available';
            InstructorF.Current_Account__c = null;
            InstructorF.RecordTypeId=rt.id;
            Database.insert(InstructorF);
            Opportunity OppF = new Opportunity();
            OppF.AccountId = Acc2.Id;
            OppF.StageName = 'Active';
            OppF.Offsite_Location__c = 'Hanover';
            OppF.Name = 'UtestF';
            OppF.Section__c='EE';
            OppF.CloseDate = Date.today();
            OppF.Start_Date__c = system.today();
            oppf.Supervisor__c = userInfo.getUserId();
            OppF.InstructorName__c = InstructorF.Id;
            Database.insert(OppF);
            OppF.Name='Utest15';
            OppF.Offsite_Location__c = 'Arlington';
            Database.update(OppF);
            Database.update(InstructorF);
            //Database.delete(OppF);
            Database.update(InstructorF);
            
        }
        
        public static testMethod void myTest4(){
            
            Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
            Account Acc2 = new Account();
            Acc2.Name = 'Test Account';
            Database.insert(Acc2);
            
            //CASE 8: Test update and stage active, section AA, Arlington
            Contact InstructorC = new Contact();
            InstructorC.LastName = 'UtestC';
            InstructorC.Employment_Section__c = null;
            InstructorC.Next_Availability__c = null;
            InstructorC.Instructor_Status__c = 'Available';
            InstructorC.Current_Account__c = null;
            InstructorC.RecordTypeId=rt.id;
            Database.insert(InstructorC);
            Opportunity OppC = new Opportunity();
            OppC.AccountId = Acc2.Id;
            OppC.StageName = 'Active';
            OppC.Offsite_Location__c = 'Hanover';
            OppC.Name = 'UtestC';
            OppC.Section__c='AA';
            OppC.Language__c= 'Japanese';
            OppC.CloseDate = Date.today();
            OppC.Start_Date__c = system.today();
            OppC.InstructorName__c = InstructorC.Id;
            oppc.Supervisor__c = userInfo.getUserId();
            Database.insert(OppC);
            OppC.Name='UtestC2';
            OppC.Offsite_Location__c = 'Arlington';
            OppC.StageName = 'Ended';
            Database.update(OppC);
            //Database.update(InstructorC);
            //OppC.StageName = 'Ended';
            //Database.update(OppC);
            //Database.update(InstructorC);
            
        }
    }