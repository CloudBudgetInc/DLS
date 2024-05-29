({
    launchInstructorPage : function(component, event, helper) {
        var commUrl = $A.get("$Label.c.Instructor_Community_Site_Prefix");
        window.open(commUrl,'_Self');
    },
    launchStudentPage : function(component, event, helper) {
        var commUrl = $A.get("$Label.c.Student_Community_Site_Prefix");
        window.open(commUrl,'_Self');
    }
})