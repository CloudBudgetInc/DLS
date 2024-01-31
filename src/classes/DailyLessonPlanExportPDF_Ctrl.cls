public without sharing class DailyLessonPlanExportPDF_Ctrl {
    public Id lessonPlanId;
    public Lesson_Plan__c lessonPlan {get; set;} 
    public String headerStr {get; set;}   
    public String dayOfWeek {get; set;}
    
    public DailyLessonPlanExportPDF_Ctrl() {
    
        lessonPlanId = ApexPages.currentPage().getParameters().get('lessonPlanId'); 
        String communityname = ApexPages.currentPage().getParameters().get('communityname');
        headerStr = 'Daily Lesson Plan ';
        
        if(communityname == null){
            communityname = 'internal';
        }        
        
        String filterStr = 'Id = \''+lessonPlanId+'\' AND Status__c = \'Completed\'';
        if(communityname == 'student'){
            filterStr += ' AND Share_with_my_student_s__c = true';
        }
        
        List<Lesson_Plan__c> lessonPlans = LessonPlanService.getLessonPlanWithLessonPlanHours(filterStr, ', Instructor__r.Name,RecordType.DeveloperName');
       
        if(lessonPlans.size() > 0){
            lessonPlan = lessonPlans[0];
            date dailyLessonPlanDate = lessonPlan.Date__c;
            Datetime dt = datetime.newInstance(dailyLessonPlanDate, Time.newInstance(0,0,0,0));
			dayOfWeek = dt.format('EEEE');
            headerStr += DateTime.newInstance(dailyLessonPlanDate.year(),dailyLessonPlanDate.month(),dailyLessonPlanDate.day()).format('MM/dd/YYYY');
        }
        
        String fileName = headerStr+'.pdf';          
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName);
    }    
}