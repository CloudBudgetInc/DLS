({
    getSignerInfoHelper : function(cmp, event, helper) {
        var action = cmp.get("c.getSignerInfo");
        var crId = cmp.get("v.costRateId");
        cmp.set("v.showMessage", false);
        cmp.set("v.showSpinner",true);

        action.setParams({
            cTName : cmp.get("v.defaultVal"),
            crId : crId,
        });
                
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            console.log(':::state:::'+state);
            if(state == "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('returnValue',JSON.parse(returnValue));
                cmp.set("v.signerMap",JSON.parse(returnValue));
                var signerInfoMap = cmp.get("v.signerMap");
                var signerValMap = cmp.get("v.signerValMap");
                var signer2Staff = '';
                var signer3Staff = '';
                
                if(signerInfoMap['StaffName'] && signerInfoMap['CurrentUser']){
                    
                    if(!signerInfoMap['SupervisorSigner1']){
                        var str = cmp.get("v.card");
                        str.title = "Error";
                        str.message = "Please fill the Contact's Supervisor Name";
                        str.buttonName = "Okay";
                        cmp.set("v.card", str);
                        cmp.set("v.showMessage", true);
                    }else {
                        if(signerInfoMap['StaffSigner2'] && (signerInfoMap['CurrentUser'] == signerInfoMap['StaffSigner2'] 
                           || signerInfoMap['SupervisorSigner1'] == signerInfoMap['StaffSigner2'])){
                            
                            signerValMap.valHRMsg = "Please select HR User for "+signerInfoMap['StaffName'];
                            signerValMap.isValidHRUser = false;
                        }else{
                            signer2Staff = signerInfoMap['StaffSigner2'];
                            signerValMap.signer2Staff = signer2Staff;
                        }
                        
                        if(signerInfoMap['StaffSigner3'] && (signerInfoMap['CurrentUser'] == signerInfoMap['StaffSigner3']
                           || signerInfoMap['SupervisorSigner1'] == signerInfoMap['StaffSigner3'])){
                            
                            signerValMap.valDlsExecMsg = "Please select DLS Executive User for "+signerInfoMap['StaffName'];
                            signerValMap.isValidDlsExecUser = false;
                        }else{
                            signer3Staff = signerInfoMap['StaffSigner3'];
                            signerValMap.signer3Staff = signer3Staff;
                        }
                    }
                    cmp.set("v.signerValMap",signerValMap); 
                    cmp.set("v.showSpinner",false);

                    if(signer2Staff && signer3Staff){
                        this.launchConga(cmp,event,helper,signer2Staff,signer3Staff)
                    }
                } else{
                    cmp.set("v.showSpinner",false);

                    if(!signerInfoMap['CurrentUser']){
                        var str = cmp.get("v.card");
                        str.title = "Error";
                        str.message = "Please fill the Contact's DLS User Name";
                        str.buttonName = "Okay";
                        cmp.set("v.card", str);
                        cmp.set("v.showMessage", true);
                    }
                }
            } else {
                console.log(":::GenSendDocuSign  Error:::",response.getError());
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                cmp.set("v.card", str);
                cmp.set("v.showMessage", true);
                cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    launchConga : function(cmp, event, helper,signer2Staff,signer3Staff) { 
        var offerLetter = ['MTT ICA','ICA DLI-W 2017','Translation and Interpretation Addendum to ICA','Translation and Interpretation ICA'];
        var userObjLookup = cmp.get("v.userObjLookup");
        var ltsSigner1 = '';
        
        if(userObjLookup.length > 0){
            ltsSigner1 = userObjLookup[0].Id;
        }
        
        if((!cmp.get("v.independContractorName")) &&  offerLetter.includes(cmp.get("v.defaultVal"))){
            var str = cmp.get("v.card");
            str.title = "Information";
            str.message = 'Please fill the Contact\'s Independent Contractor Name';
            str.buttonName = "Okay";
            cmp.set("v.card", str);
            cmp.set("v.showMessage", true);
        }else {
            cmp.set("v.showSpinner",true);
            var action = cmp.get("c.genSendDocuSign");
            cmp.set("v.showMessage", false);
            
            var sObjectName1 = cmp.get("v.sObjectName");
            var crId = cmp.get("v.costRateId");
            var cAProId = cmp.get("v.selectedCAId");
              var projectId = cmp.get("v.selectedCAId");
            action.setParams({
                recId : cmp.get("v.recordId"),
                crId : crId,
                fieldCTName : cmp.get("v.fieldVal"),
                selectedCTName : cmp.get("v.defaultVal"),
                launchedFrom : cmp.get("v.launchedFrom"),
                objName : sObjectName1,
                cAProId : cAProId,
                signer1 : ltsSigner1,
                signer2Staff : signer2Staff,
                signer3Staff : signer3Staff
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(':::state:::'+state);
                if(state == "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    console.log('::::LCR'+JSON.stringify(returnValue));
                    cmp.set("v.showSpinner",false);

                    var serverUrlSessionId = JSON.parse(returnValue.sessionIdServerURL);
                    var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                        "&serverUrl="+serverUrlSessionId["serverUrl"];
                    
                    console.log(':::***:::returnValue.congaURL:::***:::',returnValue.congaURL);
                    if(returnValue.congaURL.indexOf("&queryId=") != -1) {
                        console.log(':::***:::url:::***:::',url+returnValue.congaURL);
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": url+returnValue.congaURL
                        });
                        urlEvent.fire();
                        cmp.set("v.showSpinner",false);
                        $A.get("e.force:closeQuickAction").fire(); 
                        
                    } else if(returnValue.congaURL == "MTT") {
                        var str = cmp.get("v.card");
                        str.title = "Information";
                        str.message = "Please go to the Contact Assignment to send MTT docusign Process";
                        str.buttonName = "Okay";
                        cmp.set("v.card", str);
                        cmp.set("v.showMessage", true);
                        
                    } else {
                        var str = cmp.get("v.card");
                        str.title = "Information";
                        str.message = returnValue.congaURL;
                        str.buttonName = "Okay";
                        cmp.set("v.card", str);
                        cmp.set("v.showMessage", true);
                    }
                    
                } else {
                    cmp.set("v.showSpinner",false);
                    console.log(":::GenSendDocuSign init Error:::",response.getError());
                    var str = cmp.get("v.card");
                    str.title = "Error";
                    str.message = response.getError()[0].message;
                    str.buttonName = "Okay";
                    cmp.set("v.card", str);
                    cmp.set("v.showMessage", true);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
})