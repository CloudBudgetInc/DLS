({
	doInit : function(component, event, helper) {
        let applicant = component.get("v.applicant"),
        	 url = '/apex/RChilliResumeUploadWizardPage?skipBookmark=true&Launch=Upload&Cid='+applicant.bpats__ATS_Applicant__c+'&jobId='+applicant.bpats__Job__c+'&applicantId='+applicant.Id+'&skipUpload=true';
		
        window.open(url,'_blank');
	}
})