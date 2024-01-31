global class JobBoardController {

    /*public JobBoardController() {

    }*/

    
    global JobBoardController(LibraryContentSearch l) {
        
    }
    
    @RemoteAction
    global static Id saveJobApplication(JobApplication job, Id jobId, Id contactId) {
        system.debug('::jobappli::'+job);
        List<Job_Application__c> applicationList = new List<Job_Application__c>{
            new Job_Application__c(Referrer__c = contactId, Job_Posting__c = jobId, Contact_First_Name__c = job.firstname, Contact_Last_Name__c = job.lastname, Contact_Mobile__c = job.phone, Email__c = job.email, Referrer_Comments__c = job.comments)
        };
        List<Job_Application__c> applicationList1 = new List<Job_Application__c>();
        applicationList1 = JobApplicationService.insertJobapplication(applicationList);
        return applicationList1[0].Id;
    }
    
    global class JobApplication {
        public String firstName;
        public String lastName;
        public String phone;
        public String email;
        public String comments;
    }
    
    @RemoteAction
    global static void createJobPost(String jobObjectJSON) {
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        list<Job_Posting__c> jobPostlist = new list<Job_Posting__c>();
        Job_Posting__c post = (Job_Posting__c) System.JSON.deserialize(jobObjectJSON, Job_Posting__c.class);
        jobList.add(post);
        jobPostlist = JobPostingService.updateJobpost(jobList);
        //upsert post;
    }
    
    @RemoteAction
    global static List<Account> getInitialData() {
        return AccountService.getAccount('',' LIMIT 10');
        //return [SELECT Id, Name FROM Account LIMIT 10];
    }
    
    @RemoteAction
    global static Job_Posting__c getJobDetails(Id jobId, Id contactId) {
        
        /*return [SELECT Id, Name, Amount_of_Travel__c, City__c, Account__c, Account__r.Name, Contact_Email__c, Job_Description__c, Locations__c,
                        Eduction_Level_Required__c, How_to_Apply__c, Job_Post_Expiration_Date__c, Status__c, Hours_Per_Week__c, Job_Length__c,
                        Relocation__c, Language__c, Pay_Details__c, Year_of_Experiance__c, CreatedDate, Locations__r.Name, GeoCode__Latitude__s, GeoCode__Longitude__s,
                        Job_Title__c, Job_Type__c, Max_Salary__c, Min_Salary__c, Salary_Type__c, Start_Date__c, Travel_Required__c, Number_of_Openings__c, Qualification__c,
                    (SELECT Id, Status__c FROM Job_Requests__r WHERE Applicant__c = :contactId)
                FROM Job_Posting__c WHERE Id = :jobId];*/
                
        //List<Job_Posting__c> jobpot = JobPostingService.getJobdetails(new Set<Id>{jobId}, new Set<Id>{contactId}); 
        List<Job_Posting__c> jobpot = JobPostingService.getJobpostingByapplicant(' WHERE Id = \''+jobId+'\'',' Account__r.Name, Locations__r.Name',new Set<Id>{contactId});
        return jobpot[0];        
    }
    
    @RemoteAction
    global static Id applyJob(Id postId, Id contactId) {
        List<Job_Application__c> applicationList = new List<Job_Application__c>{
            new Job_Application__c(Applicant__c = contactId, Job_Posting__c = postId, Status__c = 'Applied')
        };
        List<Job_Application__c> applicationList1 = new List<Job_Application__c>();
        applicationList1 = JobApplicationService.insertJobapplication(applicationList);                
        //insert application;
        return applicationList1[0].Id;
    }
    
    @RemoteAction
    global static void deleteApplication(Id applicationId) {
        //Set<Id> refId = new Set<Id>();
        //List<Job_Application__c> applicationList = [SELECT Id FROM Job_Application__c WHERE Id = :applicationId];
        //List<Job_Application__c> applicationList = jobApplicationservice.getJoblist(refId, new Set<Id>{applicationId});
        
        List<Job_Application__c> applicationList = SObjectQueryService.SObjectQuery('Job_Application__c',new Set<Id>{applicationId},'');
        system.debug('::::::jobapplicantapplicationList:::'+applicationList);
        List<Job_Application__c> appList = new List<Job_Application__c>();
        if(applicationList.size() > 0) {
            for(Job_Application__c application : applicationList) {
                application.Status__c = 'Canceled';
            }
            appList = JobApplicationService.updateJobapplication(applicationList);
            //update applicationList;
        }
    }
    
    global static List<String> getJobTypePicklist() {
        List<String> service = new List<String>();
        List<Schema.PicklistEntry> servicePicklist = Job_Posting__c.Job_Type__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : servicePicklist) {
            service.add(entry.getValue());
        }
        return service;
    }
    
    global static List<String> getHoursPerWeekPicklist() {
        List<String> hoursPerWeek = new List<String>();
        List<Schema.PicklistEntry> hoursPerWeekPicklist = Job_Posting__c.Hours_Per_Week__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : hoursPerWeekPicklist) {
            hoursPerWeek.add(entry.getValue());
        }
        return hoursPerWeek;
    }
    
    global static List<String> getProximityPickList() {
        List<String> proximity = new List<String>();
        List<Schema.PickListEntry> proximityPickList = Contact.Proximity__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : proximityPicklist) {
            proximity.add(entry.getValue());
        }
        return proximity;
    }
    
    global static List<String> getJobLengthPicklist() {
        List<String> jobLength = new List<String>();
        List<Schema.PicklistEntry> jobLengthPicklist = Job_Posting__c.Job_Length__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : jobLengthPicklist) {
            jobLength.add(entry.getValue());
        }
        return jobLength;
    }
    
    global static List<String> getPayDetailsPicklist() {
        List<String> payDetails = new List<String>();
        List<Schema.PicklistEntry> payDetailsPicklist = Job_Posting__c.Pay_Details__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : payDetailsPicklist) {
            payDetails.add(entry.getValue());
        }
        return payDetails;
    }
    
    global static List<String> getAllLanguages() {
        List<String> language = new List<String>();
        List<Schema.PicklistEntry> languagePicklist = Job_Posting__c.Language__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : languagePicklist) {
            language.add(entry.getValue());
        }
        return language;
    }
    
    global static List<MTT_Location__c> getLocations() {
        List<MTT_Location__c> locationList = MTTLocationService.getMTTloaction('');
        return locationList;
        //return [SELECT Id, Name FROM MTT_Location__c]; 
    }
    
    @RemoteAction
    global static SearchParameters getSearchParameters() {
        SearchParameters parameters = new SearchParameters();
        parameters.service = getJobTypePicklist();
        parameters.language = getAllLanguages();
        parameters.payDetails = getPayDetailsPicklist();
        parameters.jobLength = getJobLengthPicklist();
        parameters.hoursPerWeek = getHoursPerWeekPicklist();
        //parameters.proximity = getProximityPickList();
        return parameters;
    }
    
    global static System.Location getLocation(String zip, Contact con) {
        Boolean zipFlag = false;
        System.Location loc;
        if(zip == '')
            zip = con.MailingPostalCode;
            zipFlag = true;
            TimezoneUtilClass ts = new TimezoneUtilClass();
            TimezoneUtilClass.location location = ts.geoCode('', '', '', 'US', zip);
            if(location.lat == null || location.lng == null) {
                location.lat = location.lng = '0';
                throw new NullLocationException('NULL');
            }
            loc = System.Location.newInstance(Double.valueOf(location.lat), Double.valueOf(location.lng));
        return loc;
    }
    
    
    
    global static List<Job> getJobList(String keyword, Contact con, String zip) {
        Id contactId = con.Id;
        List<Job_Posting__c> jobList;
        System.debug(keyword);
        System.debug(keyword.length());
        Boolean zipFlag = true;
        Boolean errorProximity = false;
        System.Location loc;
        if(zip == '') zipFlag = false;
        try {loc = getLocation(zip, con);} catch (NullLocationException e){loc = System.Location.newInstance(0, 0); errorProximity = true;}
        
        if(loc == null) {
            loc = System.Location.newInstance(0, 0);
            zipFlag = false;
        }
        
        Date today = System.today();
        
        if(keyword.length() <= 1) {
            /*jobList = [SELECT Id, Name, Amount_of_Travel__c, City__c, Account__c, Account__r.Name, Contact_Email__c, Job_Description__c, Locations__c,
                        Eduction_Level_Required__c, How_to_Apply__c, Job_Post_Expiration_Date__c, Status__c, Hours_Per_Week__c, Job_Length__c,
                        Locations__r.Location_GeoCode__Latitude__s, Locations__r.Location_GeoCode__Longitude__s,
                        Relocation__c, Language__c, Pay_Details__c, Year_of_Experiance__c, CreatedDate, Locations__r.Name, GeoCode__Latitude__s, GeoCode__Longitude__s,
                        Job_Title__c, Job_Type__c, Max_Salary__c, Min_Salary__c, Salary_Type__c, Start_Date__c, Travel_Required__c FROM Job_Posting__c WHERE Job_Post_Expiration_Date__c >= :today];*/
       
            //jobList = JobPostingService.getAwardedJobs(today);
            jobList = JobPostingService.getJobposting(' WHERE Job_Post_Expiration_Date__c ','Account__r.Name, Locations__r.Location_GeoCode__Latitude__s, Locations__r.Location_GeoCode__Longitude__s, Locations__r.Name',today);
            
        } else {
            /*jobList = [FIND :keyword IN ALL FIELDS RETURNING Job_Posting__c(Id, Name, Amount_of_Travel__c, City__c, Account__c, Account__r.Name, Contact_Email__c, Job_Description__c, Locations__c,
                        Eduction_Level_Required__c, How_to_Apply__c, Job_Post_Expiration_Date__c, Status__c, Hours_Per_Week__c, Job_Length__c,
                        Locations__r.Location_GeoCode__Latitude__s, Locations__r.Location_GeoCode__Longitude__s,
                        Relocation__c, Language__c, Pay_Details__c, Year_of_Experiance__c, CreatedDate, Locations__r.Name, GeoCode__Latitude__s, GeoCode__Longitude__s,
                        Job_Title__c, Job_Type__c, Max_Salary__c, Min_Salary__c, Salary_Type__c, Start_Date__c, Travel_Required__c WHERE Job_Post_Expiration_Date__c >= :today)][0];*/
        
            jobList = JobPostingService.getJoblist(today, keyword);
        }
        
        Set<Id> jobPostIdSet = new Set<Id>();        
        for(Job_Posting__c job : jobList)
            jobPostIdSet.add(job.Id);
        system.debug('::jobPostIdSet::'+jobPostIdSet);      
        //List<Job_Application__c> applicationList = [SELECT Id, Name, Job_Posting__c, Applicant__c, Status__c FROM Job_Application__c WHERE Job_Posting__c IN :jobPostIdSet];
      
        
        List<Job_Application__c> applicationList = jobApplicationservice.getJoblist(' WHERE Job_Posting__c ',jobPostIdSet);
      
        
        List<Job> allJobs = new List<Job>();
        
        for(Job_Posting__c job : jobList) {
            Job jobItem = new Job();
            jobItem = getJobInstance(job);
            jobItem.zipFlag = zipFlag;
            jobItem.errorProximity = errorProximity;
            jobItem.distance = loc.getDistance(System.Location.newInstance(job.Locations__r.Location_GeoCode__Latitude__s, job.Locations__r.Location_GeoCode__Longitude__s), 'mi');
            System.debug('jobItem.distance' + jobItem.distance + job.Locations__r.Location_GeoCode__Latitude__s + job.Locations__r.Location_GeoCode__Longitude__s);
            jobItem.startLat = loc.latitude;
            jobItem.startLng = loc.longitude;
            for(Job_Application__c application : applicationList) {
                if(application.Job_Posting__c == job.Id) {
                    jobItem.popularScore++;
                    if(application.Applicant__c == contactId) {
                        jobItem.applicationId = application.Id;
                        jobItem.applicationStatus = application.Status__c;
                    }
                }
            }
            allJobs.add(jobItem);
        }
        System.debug('allJobs');
        return allJobs;
    }
    
    @RemoteAction
    global static List<Job> getAwardedJobs(Id userId) {
        Job jobItem = new Job();
        Id contactId = getContact(userId).Id;
        List<Job_Posting__c> jobList;
        List<Job> awardedJobs = new List<Job>();
        Set<Id> jobAppSetId = new Set<Id>();
        //Date refdate;
        if(contactId != null){
            List<Job_Application__c> jobApptList = jobApplicationservice.getJoblist(' WHERE Status__c = \'Awarded\' AND Applicant__c ',new Set<Id>{contactId});
            //List<Job_Application__c> jobApptList = jobApplicationservice.getJoblist(' WHERE Applicant__c = \'' +contactId+ '\' AND Status__c = \'Awarded\'');  
            jobAppSetId = JobApplicationTranslator.jobApplicationinfo(jobApptList);
            
            /*jobList = [SELECT Id, Name, Amount_of_Travel__c, City__c, Account__c, Account__r.Name, Contact_Email__c, Job_Description__c, Locations__c,
                        Eduction_Level_Required__c, How_to_Apply__c, Job_Post_Expiration_Date__c, Status__c, Hours_Per_Week__c, Job_Length__c,
                        Relocation__c, Language__c, Pay_Details__c, Year_of_Experiance__c, CreatedDate, Locations__r.Name, GeoCode__Latitude__s, GeoCode__Longitude__s,                                                //Job_Requests__c
                        Job_Title__c, Job_Type__c, Max_Salary__c, Min_Salary__c, Salary_Type__c, Start_Date__c, Travel_Required__c FROM Job_Posting__c WHERE Id IN (SELECT Job_Posting__c FROM Job_Application__c WHERE Applicant__c = :contactId AND Status__c = 'Awarded')];*/
        
            //jobList = JobPostingService.getAwardedJobs(refdate, jobAppSetId);
            
            jobList = SObjectQueryService.SObjectQuery('Job_Posting__c',jobAppSetId,'');
            system.debug(':::jobpostjobList::::'+jobList);
            for(Job_Posting__c job : jobList)
                awardedJobs.add(getJobInstance(job));
                return awardedJobs;
        }
        return null;
    }
    
    @RemoteAction
    global static List<Job> getAppliedJobs(Id userId) {
        Job jobItem = new Job();
        Id contactId = getContact(userId).Id;
        List<Job_Posting__c> jobList;
        List<Job> awardedJobs = new List<Job>();
        Date refdate;
        Set<Id> jobAppSetId = new Set<Id>();
        
        if(contactId != null){
            List<Job_Application__c> jobApptList = jobApplicationservice.getJoblist(' WHERE (Status__c = \'Awarded\' OR Status__c = \'Applied\') AND Applicant__c ',new Set<Id>{contactId});
            /*jobList = [SELECT Id, Name, Amount_of_Travel__c, City__c, Account__c, Account__r.Name, Contact_Email__c, Job_Description__c, Locations__c,
                        Eduction_Level_Required__c, How_to_Apply__c, Job_Post_Expiration_Date__c, Status__c, Hours_Per_Week__c, Job_Length__c,
                        Relocation__c, Language__c, Pay_Details__c, Year_of_Experiance__c, CreatedDate, Locations__r.Name, GeoCode__Latitude__s, GeoCode__Longitude__s,                                                //Job_Requests__c
                        Job_Title__c, Job_Type__c, Max_Salary__c, Min_Salary__c, Salary_Type__c, Start_Date__c, Travel_Required__c FROM Job_Posting__c WHERE Id IN (SELECT Job_Posting__c FROM Job_Application__c WHERE Applicant__c = :contactId AND (Status__c = 'Awarded' OR Status__c = 'Applied'))];*/
            
            //jobList = JobPostingService.getAwardedJobs(refdate, jobAppSetId);
            
            jobAppSetId = JobApplicationTranslator.jobApplicationinfo(jobApptList);
            
            jobList = SObjectQueryService.SObjectQuery('Job_Posting__c',jobAppSetId,'');
            
            for(Job_Posting__c job : jobList)
                awardedJobs.add(getJobInstance(job));
            return awardedJobs;
        }
        return null;
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 9, 2017: Apex controller class for this JobBoardComponen
        to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    
    @RemoteAction
    global static Id getUserconId(){
        
        Id userId = UserInfo.getUserId();            
        List<User> usrList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
        Id userconId = usrList[0].ContactId;    
        return userconId;
    }
    
    global static JobBoardController.Job getJobInstance(Job_Posting__c job) {
        Job jobItem = new Job();
        jobItem.id = job.Id;
        jobItem.title = job.Job_Title__c;
        jobItem.service = job.Job_Type__c;
        jobItem.jobLength = job.Job_Length__c;
        jobItem.location = job.Locations__c;
        jobItem.locationName = job.Locations__r.Name;
        jobItem.travelRequired = job.Travel_Required__c;
        jobItem.relocationRequired = job.Relocation__c;
        jobItem.language = job.Language__c;
        jobItem.payDetails = job.Pay_Details__c;
        jobItem.description = job.Job_Description__c;
        jobItem.city = job.City__c;
        jobItem.account = job.Account__c;
        jobItem.accountName = job.Account__r.Name;
        jobItem.amountOfTravel = job.Amount_of_Travel__c;
        jobItem.email = job.Contact_Email__c;
        jobItem.educationLevel = job.Eduction_Level_Required__c;
        jobItem.howToApply = job.How_to_Apply__c;
        jobItem.expirationDate = job.Job_Post_Expiration_Date__c;
        jobItem.status = job.Status__c;
        jobItem.hoursPerWeek = job.Hours_Per_Week__c;
        jobItem.experience = job.Year_of_Experiance__c;
        jobItem.maxSalary = job.Max_Salary__c;
        jobItem.minSalary = job.Min_Salary__c;
        jobItem.startDate = job.Start_Date__c;
        jobItem.createdDate = job.CreatedDate;
        jobItem.name = job.Name;
        jobItem.locationLat = job.GeoCode__Latitude__s;
        jobItem.locationLng = job.GeoCode__Longitude__s;
        return jobItem;
    }
    
    global Decimal calculateDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2){
        Double Radius = 6371.00;
        Double dLat = toRadians(lat2-lat1);
        Double dLon = toRadians(lon2-lon1);
        Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(toRadians(lat1)) *   Math.cos(toRadians(lat2)) *
        Math.sin(dLon/2) * Math.sin(dLon/2);
        Double c = 2 * Math.asin(Math.sqrt(a));
        return Radius * c * .62;
    }


    global Double toRadians(Decimal degree){
        Double res = degree * 3.1415926 / 180;
        return res;
    }
    
    
    @RemoteAction
    global static JobList getAllJobs(Id userId, String keyword, String zip) {
        System.debug('JobList Called');
        JobList jobs; //(FilterParameters) System.JSON.deserialize(filterJson, FilterParameters.class);
        Contact con = getContact(userId);
        
        System.debug('Calling JobList');
        
        jobs = new JobList(userId, keyword, con, zip);
        system.debug(':jobs::'+jobs);
        return jobs;
    }
    
    global static Contact getContact(Id userId) {
        Contact c = new Contact();
        List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},',Contact.Name,Contact.MailingPostalCode');
        //List<User> userList = [SELECT ContactId, Contact.Name, Contact.MailingPostalCode FROM User WHERE Id = :userId];
        if(UserList.size() > 0) {
            c.Id = userList[0].ContactId;
            c.MailingPostalCode = userList[0].Contact.MailingPostalCode;
        }
        
        return c;
    }
        
    global static JobPreference getJobPreference(Id contactId) {
        JobPreference userJobPreference = new JobPreference();
        System.debug(userJobPreference);
        //List<Contact> contactList = [SELECT Id, MailingPostalCode, Name, Services__c, Location__c, Available_for_Travel__c, Available_for_Relocation__c, Available_Hours_per_week__c, Job_Length__c, Proximity__c FROM Contact WHERE Id = :contactId];
        List<Contact> contactList = SObjectQueryService.SObjectQuery('Contact',new Set<Id>{contactId},'');
        System.debug(contactList);
        if(contactList != null && contactList.size() > 0) {
            userJobPreference.preferedService = contactList[0].Services__c;
            userJobPreference.preferedJobLength = contactList[0].Job_Length__c;
            userJobPreference.preferedLocation = contactList[0].Location__c;
            userJobPreference.isAvailableForTravel = contactList[0].Available_for_Travel__c;
            userJobPreference.isAvailableForRelocation = contactList[0].Available_for_Relocation__c;
            userJobPreference.preferedHoursPerWeek = contactList[0].Available_Hours_per_week__c;
            userJobPreference.Name = contactList[0].Name;
            userJobPreference.contactId = contactList[0].Id;
            userJobPreference.preferedProximity = contactList[0].Proximity__c;
            userJobPreference.postalCode = contactList[0].MailingPostalCode;
        }
        return userJobPreference;
    }
    
    global class JobList {
        List<Job> jobs;
        JobPreference userPreference;
        FilterParameters filter;
        SearchParameters search;
        public JobList() {
            this.jobs = getJobList(null, null, '');
            this.search = getSearchParameters();
            this.userPreference = new JobPreference();
            this.filter = new FilterParameters();
        }
        
        public JobList(Id userId, String keyword, Contact con, String zip) {
            this.jobs = getJobList(keyword, con, zip);
            this.search = getSearchParameters();
            this.userPreference = getJobPreference(con.Id);
            this.userPreference.postalCode = con.MailingPostalCode;
            this.filter = new FilterParameters();
        }
        
        public JobList(Id userId, FilterParameters filter) {
            this.jobs = getJobList(filter.keyword, getContact(userId), '');
            this.search = getSearchParameters();
            this.userPreference = getJobPreference(getContact(userId).Id);
            this.filter = filter;
        }
    }
    
    
    @RemoteAction
    global static void setUserPreference(String userPreferenceJsonString) {
        JobPreference userPreference = (JobPreference) System.JSON.deserialize(userPreferenceJsonString, JobPreference.class);
        Contact con = new Contact();
        System.debug(userPreference);
        //Contact Id
        if(userPreference.contactId != null)
            con.Id = userPreference.contactId;
        
        //Service
        if(userpreference.preferedService != null)
            con.Services__c = userPreference.preferedService;
        
        //Job Length
        if(userpreference.preferedJobLength != null)
            con.Job_Length__c = userPreference.preferedJobLength;
            
        //Is Available for Relocation
        if(userpreference.isAvailableForRelocation != null)
            con.Available_for_Relocation__c = userPreference.isAvailableForRelocation;
        
        //Is Available For Travel
        if(userpreference.isAvailableForTravel != null)
            con.Available_for_Travel__c = userPreference.isAvailableForTravel;
        
        //Prefered Hours 
        if(userpreference.preferedHoursPerWeek != null)
            con.Available_Hours_per_Week__c = userPreference.preferedHoursPerWeek;
        
        //Proximity
        if(userpreference.preferedProximity != null)
            con.Proximity__c = userPreference.preferedProximity;
            
        System.debug(con);
        update con;
    }
    
    global class Job {
        public Id id;
        public String title;
        public String service;
        public String jobLength;
        public String location;
        public String locationName;
        public boolean travelRequired;
        public boolean relocationRequired;
        public String language;
        public String payDetails;
        public Integer score = 0;
        public String description;
        public String city;
        public Id account;
        public String accountName;
        public Decimal amountOfTravel;
        public String email;
        public String educationLevel;
        public String howToApply;
        public Date expirationDate;
        public String status;
        public String hoursPerWeek;
        public Decimal experience;
        public Decimal maxSalary;
        public Decimal minSalary;
        public Date startDate;
        public DateTime createdDate;
        public String name;
        public Integer popularScore = 0;
        public Id applicationId;
        public String applicationStatus;
        public Decimal distance;
        public Boolean zipFlag;
        public Boolean errorProximity;
        public Decimal locationLat;
        public Decimal locationLng;
        public Decimal startLat;
        public Decimal startLng;
        public Date postingDate;
    }
    
    global class FilterParameters {
        public List<String> service;
        public List<String> jobLength;
        public Id Locaiton;
        public String travelRequired;
        public String relocationRequired;
        public List<String> hoursPerWeek;
        public String language;
        public List<String> payDetail;
        public String sortBy;
        public String keyword;
    }
    
    global class JobPreference {
        public String preferedService;
        public String preferedJobLength;
        public Id preferedLocation;
        public boolean isAvailableForTravel;
        public boolean isAvailableForRelocation;
        public String preferedHoursPerWeek;
        public String Name;
        public Decimal preferedProximity;
        public String postalCode;
        public Id contactId;
        public String zip;
    }
    
    global class SearchParameters {
        public List<String> service;
        public List<String> language;
        public List<String> payDetails;
        public List<String> jobLength;
        public List<String> hoursPerWeek;
        public List<MTT_Location__c> location;
        public List<String> proximity;
        public SearchParameters() {
            service = new List<String>();
            language = new List<String>();
            payDetails = new List<String>();
            jobLength = new List<String>();
            hoursPerWeek = new List<String>();
            location = new List<MTT_Location__c>();
        }
    }
    
    global class NullLocationException extends Exception{
    }
    
   
    
    global JobBoardController() {}
    
}