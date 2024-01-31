@isTest
public class JobControllerTest {
    @testSetup static void setup(){
        List<Job_Application__c> jobpostinglist = TestClassUtil.createTestJobApplication();
        List<User> UserList = TestClassUtil.createTestUsers();   
    }
    public static testmethod void jobTest() {
        JobBoardController.getInitialData();
        JobBoardController.getJobTypePicklist();
        JobBoardController.getHoursPerWeekPickList();
        JobBoardController.getProximityPicklist();
        JobBoardController.getJobLengthPicklist();
        JobBoardController.getPayDetailsPicklist();
        JobBoardController.getAllLanguages();
        JobBoardController.getLocations();
        JobBoardController.getSearchParameters();
        Contact con = [SELECT Id,MailingPostalCode FROM Contact LIMIT 1];
         
        List<User> UserList = [SELECT Id, Name,ContactId FROM User Where ContactId != null LIMIT 1];
        system.debug('JobControllerTest::jobTest:UserList'+UserList);
        
        List<Job_Application__c> jobpostlist = [Select Id, Name, Status__c, Applicant__c From Job_Application__c Limit 2];
        jobpostlist[0].Status__c = 'Awarded';
        jobpostlist[0].Applicant__c = UserList[0].ContactId;
        update jobpostlist;
        
        if(UserList != null && UserList.size() > 0){
            JobBoardController.getAwardedJobs(UserList[0].Id);
            JobBoardController.getAppliedJobs(UserList[0].Id);
            JobBoardController.getAllJobs(UserList[0].Id,'asd','');
        }
        //JobBoardController.JobList jlist1 = new JobBoardController.JobList();
        JobBoardController.JobList jlist = new JobBoardController.JobList(UserList[0].Id,'asd',con,'');
        
        Decimal dec= 0.5;
        JobBoardController j = new JobBoardController();
        j.calculateDistance(dec,dec,dec,dec);
        j.toRadians(0.0);
        List<Job_Posting__c> jobpostingList = new List<Job_Posting__c>{
                                     new Job_Posting__c(city__c = 'asd', Job_Post_Expiration_Date__c = system.today(), Status__c = 'Applied'),
                                     new Job_Posting__c(city__c = 'asd', Job_Post_Expiration_Date__c = system.today().addDays(1))
                                    };
        insert jobpostingList;
        
        List<Job_Posting__c> postList = [SELECT Id, City__c, Job_Post_Expiration_Date__c FROM Job_Posting__c LIMIT 2];
        String jsonPost = JSON.serializePretty(postList[0]);
        JobBoardController.createJobPost(jsonPost);
        
        if(postList != null && con != null){
            JobBoardController.getJobDetails(postList[0].Id, con.Id);
            JobBoardController.applyJob(postList[0].Id, con.Id);
            
            Job_Application__c request = [SELECT ID,Applicant__r.MailingPostalCode FROM Job_Application__c LIMIT 1];
            JobBoardController.deleteApplication(request.Id);
            JobBoardController.getJobList('asd', con, '');
            JobBoardController.getJobList('', con, '');
            //JobBoardController.JobList jlist = new JobBoardController.JobList();
            
        }
    }
    public static testMethod void myTest(){
        List<Contact> conList = [SELECT Id, MailingPostalCode, Name, Services__c, Location__c, Available_for_Travel__c, Available_for_Relocation__c, Available_Hours_per_week__c, Job_Length__c, Proximity__c FROM Contact LIMIT 2];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        conList[0].Available_Hours_per_week__c = '11-20hrs';
        conList[0].Job_Length__c = '';
        conList[0].Proximity__c = 5;
        conList[0].Services__c = '';
        update conList;
        
        JobBoardController.JobPreference job = new JobBoardController.JobPreference();
        job.ContactId = conList[0].Id;
        job.preferedProximity = conList[0].Proximity__c;
        job.zip = '23456';
        job.postalCode = conList[0].MailingPostalCode;
        job.Name = conList[0].Name;
        job.preferedService = conList[0].Services__c;
        job.preferedJobLength = conList[0].Job_Length__c;
        job.preferedLocation = conList[0].Location__c;
        job.isAvailableForTravel = conList[0].Available_for_Travel__c;
        job.isAvailableForRelocation = conList[0].Available_for_Relocation__c;
        job.preferedHoursPerWeek = conList[0].Available_Hours_per_week__c;
        String jobSerialize = JSON.serializePretty(job);
        
        JobBoardController.FilterParameters filter = new JobBoardController.FilterParameters();
        filter.keyword = 'abc';
        JobBoardController.JobList jlist = new JobBoardController.JobList(userList[0].Id,filter);
        JobBoardController.getLocation('0',conList[0]);
        JobBoardController.setUserPreference(jobSerialize);
        JobBoardController.getJobPreference(conList[0].Id);
        //JobBoardController.saveJobApplication();
        LibraryContentSearch lib = new LibraryContentSearch();
        JobBoardController ctrl = new JobBoardController(lib);
        
        JobBoardController.JobApplication jb = new JobBoardController.JobApplication();
        jb.firstName = 'Test';
        jb.lastName = 'Job';
        jb.phone = '4565434543';
        jb.email = 'test@gmail.com';
        jb.comments = 'Test';
        List<Job_Application__c> jobpostlist = [Select Id, Name, Status__c, Applicant__c, Job_Posting__c From Job_Application__c Limit 2];
        system.debug(':::jobpostlist'+jobpostlist);
        
        JobBoardController.saveJobApplication(jb,jobpostlist[0].Job_Posting__c,conList[0].Id);
    }
}