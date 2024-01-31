({
    getMyProfileRecords: function(cmp, event, helper) {
        var contactId = cmp.get("v.recordId");
        cmp.set("v.recordId",contactId);
        var workExpTableColumns = [{
                'label': 'Company Name',
                'name': 'nameOfCompany',
                'type': 'String',
            'sortable':false,
                'sortable': true,
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable':false,
                'visible': false,
            },
                {
                'label': 'sobjectName',
                'name': 'sobjectName',
                'type': 'String',
                    'sortable':false,
                'visible': false,
            },{
                'label': 'RecordType',
                'name': 'recordType',
                'type': 'String',
                'sortable':false,
                'visible': false,
            },
            {
                'label': 'Role/Job title',
                'name': 'roleTitle',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'width': 160
            },
            {
                'label': 'Start Date',
                'name': 'stardDateStr',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'width': 180
            },
            {
                'label': 'End Date',
                'name': 'endDateStr',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'width': 180
            },
            {
                'label': 'Service(S)',
                'name': 'services',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'City',
                'name': 'city',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'State',
                'name': 'state',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'Country',
                'name': 'country',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'FT/PT',
                'name': 'ftPt',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': false,
                'width': 150
            },
            {
                'label': 'Average Hrs Per Week',
                'name': 'averageHrsPerWeek',
                'type': 'String',
                'sortable':false,
                'visible': false,
                'width': 150
            },
            {
                'label': 'Total # of Hours',
                'name': 'totalHoursPerformed',
                'type': 'String',
                'sortable':false,
                'visible': false,
                'width': 150
            },
            {
                'label': 'Description',
                'name': 'description',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': false,
                'width': 150
            }
        ];

        var educationTableColumns = [{
                'label': 'College School',
                'name': 'collegeSchool',
                'type': 'String',
                'width': 250,
            'sortable':false,
                'truncate': {},
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable':false,
                'visible': false,
            },{
                'label': 'sobjectName',
                'name': 'sobjectName',
                'type': 'String',
                'sortable':false,
                'visible': false,
            },
            {
                'label': 'College School Type',
                'name': 'collegeSchoolType',
                'type': 'String',
                'sortable':false,
                'width': 150,
                'truncate': {},
            },
            {
                'label': 'Location',
                'name': 'location',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'width': 200

            },
            {
                'label': 'Degree',
                'name': 'degree',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'Degree Level',
                'name': 'degreeLevel',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 150
            },
            {
                'label': 'Field Of Concentration',
                'name': 'fieldOfConcentration',
                'type': 'String',
                'truncate': {},
                'sortable':false,
                'visible': true,
                'width': 160
            },
            {
                'label': 'Year Of Completion',
                'name': 'yearOfCompletion',
                'type': 'String',
                'sortable':false,
                'truncate': {},
                'visible': true,
                'width': 165
            }
        ];


        var languageTableColumns = [{
                'label': 'Language Name',
                'name': 'languageName',
                'type': 'String',
            'sortable':false,
            	'width': 300
        },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable': false,
                'visible': false,
                'width': 300
            },{
                'label': 'sobjectName',
                'name': 'sobjectName',
                'type': 'String',
                'sortable':false,
                'visible': false,
                'width': 300
            },
            {
                'label': 'Native Language',
                'name': 'nativeLanguage',
                'sortable':false,
                'type': 'checkbox',
                'width': 300                
            },
            {
                'label': 'Speaking proficiency',
                'name': 'speaking',
                'sortable':false,
                'type': 'String',
                'width': 300
            },
            {
                'label': 'Listening proficiency',
                'name': 'listening',
                'sortable':false,
                'type': 'String',
                'width': 330
            }
        ];
        var skillTableColumns = [{
                'label': 'Skill Name',
                'name': 'skillName',
            'sortable':false,
                'type': 'String',
                'truncate': {},
                 'width': 210,

            },{
                'label': 'sobjectName',
                'name': 'sobjectName',
                'sortable':false,
                'type': 'String',
                'visible': false,
            },
                                 {
                'label': 'From language',
                'name': 'fromLanguage',
                'sortable':false,
                'type': 'String',
				'width': 220,
            },
                                 {
                'label': 'To Language',
                'name': 'toLanguage',
                'sortable':false,
                'type': 'String',
				'width': 200,
            },
                                 {
                'label': 'Rating',
                'name': 'rating',
                'type': 'String',
				'sortable':false,
				'width': 200,
            },
                                 {
                'label': 'skill verification',
                'name': 'skillVerification',
                'type': 'String',
				'sortable':false,
                'width': 200,

            },
                                 {
                'label': 'DLI qualified',
                'name': 'dliQualified',
                'type': 'String',
				'sortable':false,
                'width': 200,

            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable':false,
                'truncate': {
                    "characterLength": 10,
                },
                'visible': false,
				'width': 200,
            },
        ];

        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            "massSelect": false,
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                	"visible":function(row){
 							return row.status != "Deleted"
						 },
                    "id": "editicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/edit_60.png"
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "visible":function(row){
 							return row.status == "Deleted"
						 },
                    "id": "deleteicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/delete_60.png",
                }
            ],
            "rowClass":function (row) { 
                          if(row.isChanged == true)
                          return "rowColour";
                          },
            "rowActionPosition": 'right',
            "paginate": false,
            "searchBox": false
        };

        //configuration for experience
        var experienceTableConfig = {
            "massSelect": false,
            "globalAction": [],
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                	"visible":function(row){
 							return row.status != "Deleted"
						 },
                    "id": "editicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/edit_60.png"
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "visible":function(row){
 							return row.status == "Deleted"
						 },
                    "id": "deleteicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/delete_60.png",
                }
            ],
            "rowClass":function (row) { 
                          if(row.isChanged == true)
                            return "rowColour";
                          },
            "rowActionPosition": 'right',
            "paginate": false,
            "searchBox": false

        };
        // Configuration table for Education and Experience
        var eduTableConfig = {
            "massSelect": false,
            "globalAction": [],
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                	"visible":function(row){
 							return row.status != "Deleted"
						 },
                    "id": "editicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/edit_60.png"
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "visible":function(row){
 							return row.status == "Deleted"
						 },
                    "id": "deleteicon",
                    "src": "/resource/SLDS_2_1_3/assets/icons/action/delete_60.png",
                }
            ],
            "rowClass":function (row) { 
                         if(row.isChanged == true)
                          return "rowColour";
                         },
            "rowActionPosition": 'right',
            "paginate": false,
            "searchBox": false

        };

        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getProfileInformation');
        server.callServer(
                          action, {contactId : contactId},
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                cmp.set("v.contactRec", JSON.parse(JSON.stringify(result.contactRec)));
                cmp.set("v.tableConfig", tableConfig);
                cmp.set("v.eduTableConfig", eduTableConfig);
                cmp.set("v.experienceTableConfig", experienceTableConfig);
                cmp.set("v.languageTableColumns", languageTableColumns);
                cmp.set("v.skillTableColumns", skillTableColumns);
                cmp.set("v.workExpColumns", workExpTableColumns);
                cmp.set("v.educationTableColumns", educationTableColumns);
                cmp.set("v.profileInfo", result);
                cmp.find("Known Language").initialize({
                    "order": "asc"
                });
                cmp.find("Skill").initialize({
                    "order": "asc"
                });
                cmp.find("Experience").initialize({
                    "order": "asc"
                });
                cmp.find("Education").initialize({
                     "order":[],
                    "order": "asc"
                });
            }),
            $A.getCallback(function(errors) {
           		helper.showToast(cmp, event, helper, 'error', '', errors[0], 'sticky');
            }),
            false,
            false,
            false
        );
    },
                          
     updateContact: function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        const server = cmp.find('server');
        const action = cmp.get('c.updateContactRecord');
        var param = {};
        var profileInfo = cmp.get("v.profileInfo");
        param.contactRecord = JSON.stringify(profileInfo.contactRec);
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                helper.showToast(cmp, event, helper, 'success', '', 'Contact Information updated successfully', 'sticky');
                cmp.set("v.contactRec", cmp.get("v.profileInfo.contactRec"));
                cmp.set('v.viewMode', true);
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                helper.showToast(cmp, event, helper, 'error', '', errors[0], 'sticky');
                cmp.set("v.showSpinner", false);
            }),
            false,
            false,
            false
        );
    },
    showToast: function(component, event, helper, type, title, message, mode) {
    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    },
     getParameterByName: function(cmp, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
         console.log('url is',url);
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
         console.log('regex is',regex);
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
})