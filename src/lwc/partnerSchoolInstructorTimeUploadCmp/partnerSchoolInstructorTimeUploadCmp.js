import {
    LightningElement,
    track,
    wire
} from 'lwc';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import Momentjs from '@salesforce/resourceUrl/MomentjsResource';
import getInstructorIdsByProjectId from '@salesforce/apex/PartnerSchoolTimeSheetUploadCtrl.getInstructorIdsByProjectId';
import saveTimeEntries from '@salesforce/apex/PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries';
import LightningConfirm from "lightning/confirm";

const columns = [{
        label: 'Date',
        fieldName: 'Date',
        type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        },
        sortable: true
    },
    {
        label: 'Hours',
        fieldName: 'Hours',
        type: 'number',
        editable: true
    },
    {
        label: 'Late Cancellation',
        fieldName: 'LateCancellation',
        type: 'boolean',
        editable: true
    },
    {
        label: 'Cancellation Reason',
        fieldName: 'CancellationReason',
        type: 'string',
        editable: true
    },
    {
        label: 'Internal Comment',
        fieldName: 'Comments',
        type: 'string',
        editable: true
    }
];

const dayMapping = {
    'Date': 'dateVal',
    'Hours': 'dayHours',
    'Comments': 'comments',
    'LateCancellation': 'lateCancellation',
    'CancellationReason': 'cancellationReason'
}

export default class PartnerSchoolInstructorTimeUploadCmp extends LightningElement {
    parserInitialized = false;
    loading = false;
    @track _results;
    @track _rows;
    @track filter = {};
    @track disableFilter = {
        person: true,
        task: true
    };
    selectedProject;
    columns = columns;
    filteredData = [];
    instructorIds = [];
    showTable = false;
    @track sortBy;
    @track sortDirection;
    idWithfilterDataMap = {};
    @track disableProjFilter = {
        instructor: true,
        task: true
    };
    @track toastMsg = {
        show: false
    };

    renderedCallback() {
        if (!this.parserInitialized) {
            Promise.all([
                    loadScript(this, PARSER),
                    loadScript(this, Momentjs)
                ]).then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }

    handleInputChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            this.loading = true;
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    let _rows = [],
                        i = 1;

                    for (let row of [...results.data]) {
                        row._id = new Date().getTime() + '~' + i;
                        if (row.Date) {
                            row.Date = moment(row.Date).format('YYYY-MM-DD');
                        }

                        if (row.Comments) {
                            let cmnts = (row.Comments).toLowerCase();
                            row.LateCancellation = cmnts.indexOf('late') != -1 || cmnts.indexOf('cancel') != -1;
                            if (row.LateCancellation) {
                                row.CancellationReason = row.Comments;
                                row.Comments = '';
                            }
                        }
                        _rows.push(row);
                        i++;
                    }
                    this._rows = _rows;
                    this.loading = false;
                },
                error: (error) => {
                    console.error(error);
                    this.loading = false;
                }
            })
        }
    }

    get showFilters() {
        return this._rows && this._rows.length > 0;
    }

    get projectoptions() {
        let projectsTitles = this._rows.map(a => a.ProjectTitle),
            projectsFromFile = [{
                label: '--SELECT--',
                value: ''
            }],
            projectsTitlesFromFiles = [],
            removeSelectedProject = true;

        for (let projTitle of projectsTitles) {
            if (projTitle && projTitle != '' && projectsTitlesFromFiles.indexOf(projTitle) == -1) {
                if (this.filter.project == projTitle) {
                    removeSelectedProject = false;
                }
                projectsTitlesFromFiles.push(projTitle);
                projectsFromFile.push({
                    label: projTitle,
                    value: projTitle
                });
            }
        }

        if ((removeSelectedProject || projectsFromFile.length < 2) && this.template.querySelector('[data-id="projlookup"]')) {
            this.template.querySelector('[data-id="projlookup"]').handleRemove();
            this.filter.project = '';
        }

        return projectsFromFile;
    }

    get instructoroptions() {
        let instructors = this._rows.map(a => {
                if (a.ProjectTitle == this.filter.project) return a.Person
            }),
            instructorsOptions = [{
                label: '--SELECT--',
                value: ''
            }],
            PersonFromFiles = [],
            removeSelectedInstructor = true;

        for (let instructor of instructors) {
            if (instructor && instructor != '' && PersonFromFiles.indexOf(instructor) == -1) {
                if (this.filter.person == instructor) {
                    removeSelectedInstructor = false;
                }
                PersonFromFiles.push(instructor);
                instructorsOptions.push({
                    label: instructor,
                    value: instructor
                });
            }
        }
        if ((removeSelectedInstructor || instructorsOptions.length < 2) && this.template.querySelector('[data-id="inslookup"]')) {
            this.template.querySelector('[data-id="inslookup"]').handleRemove();
            this.filter.person = '';
        }
        return instructorsOptions;
    }

    get taskoptions() {
        let tasks = this._rows.map(a => {
                if (a.ProjectTitle == this.filter.project && a.Person == this.filter.person) return a.Task
            }),
            tasksOptions = [{
                label: '--SELECT--',
                value: ''
            }],
            tasksFromFiles = [],
            removeSelectedTask = true;
        tasks.sort();
        for (let task of tasks) {
            if (task && task != '' && tasksFromFiles.indexOf(task) == -1) {
                if (this.filter.task == task) {
                    removeSelectedTask = false;
                }
                tasksFromFiles.push(task);
                tasksOptions.push({
                    label: task,
                    value: task
                });
            }
        }
        if ((removeSelectedTask || tasksOptions.length < 2) && this.template.querySelector('[data-id="tasklookup"]')) {
            this.template.querySelector('[data-id="tasklookup"]').handleRemove();
            this.filter.task = '';
        }
        return tasksOptions;
    }

    handleFilterChange(event) {
        let filterValue = event.target.value;
        this.filter[event.target.name] = filterValue;
        if (event.target.name == 'project') {
            this.disableFilter['person'] = !(filterValue && filterValue != '');
        } else if (event.target.name == 'person') {
            this.disableFilter['task'] = !(filterValue && filterValue != '');
        }

    }

    renameKeys(obj, newKeys) {
        const keyValues = Object.keys(obj).map(key => {
            const newKey = newKeys[key] || key;
            return {
                [newKey]: obj[key]
            };
        });
        return Object.assign({}, ...keyValues);
    }

    get ptFilter() {
        return this.selectedProject && this.selectedProject.Id ? "AcctSeed__Project__c = '" + this.selectedProject.Id + "' AND Project_Task_Type__c != 'Material budget'" : '';
    }

    get contactFilter() {
        return "RecordType.DeveloperName = 'Candidate' AND Id IN ('" + this.instructorIds.join("','") + "')";
    }

    @wire(getInstructorIdsByProjectId, {
        projectId: '$selectedProject.Id'
    })
    searchResult(value) {
        const {
            data,
            error
        } = value; // destructure the provisioned value
        if (data) {
            this.instructorIds = JSON.parse(data);
            this.disableProjFilter.instructor = this.instructorIds.length < 0;
            this.disableProjFilter.task = this.instructorIds.length < 0;
        } else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
        }
    };

    async cancel() {
        const result = await LightningConfirm.open({
            message: 'Are you sure want to cancel?',
            theme: 'warning', // a red theme intended for error states
            label: 'Warning!', // this is the header text
        });
        if (result) {
            this._rows = undefined;
            this._results = undefined;
            this.showTable = false;
        }
    }

    handleProjectSelection(event) {
        this.selectedProject = {
            ...event.detail.selectedRecord
        };
        this.template.querySelector('[data-id="inslookup"]').handleRemove();
        this.template.querySelector('[data-id="tasklookup"]').handleRemove();
        this.disableProjFilter = {
            instructor: true,
            task: true
        };
    }

    handleInstructorSelection(event) {
        this.selectedInstructor = {
            ...event.detail.selectedRecord
        };
    }

    handlePTSelection(event) {
        this.selectedPT = {
            ...event.detail.selectedRecord
        };
    }

    validateFilter(event) {
        this.showTable = false;
        let isValid = true;
        for (let combobox of this.template.querySelectorAll('lightning-combobox')) {

            if (!combobox.checkValidity()) {
                isValid = false;
            }
            combobox.reportValidity();
        }
        for (let lookup of this.template.querySelectorAll('c-lookup')) {

            if (!lookup.checkValidity()) {
                isValid = false;
            }
            lookup.reportValidity();
        }

        if (isValid) {
            this.applyFilter();
        }
    }

    applyFilter() {
        let filteredData = [],
            allRows = [...this._rows],
            idWithfilterDataMap = {};

        for (let row of allRows) {
            if (row.ProjectTitle == this.filter.project && row.Person == this.filter.person && row.Task == this.filter.task) {
                filteredData.push(row);
                idWithfilterDataMap[row._id] = row;
            }
        }
        this.filteredData = filteredData;
        this.idWithfilterDataMap = idWithfilterDataMap;
        this.showTable = true;
    }

    validateSave() {
        let weekRangeDaysMap = {},
            filteredData = [],
            idWithfilterDataMap = JSON.parse(JSON.stringify(this.idWithfilterDataMap));
        const dt = this.template.querySelector('lightning-datatable');
        for (let changedData of JSON.parse(JSON.stringify(dt.draftValues))) {
            idWithfilterDataMap[changedData._id] = Object.assign(idWithfilterDataMap[changedData._id], changedData);
        }
        filteredData = Object.values(idWithfilterDataMap);
        this.filteredData = filteredData;
        let idsToRemove = [];

        for (let data of JSON.parse(JSON.stringify(this.filteredData))) {
            let startOfWeek = moment(data.Date).startOf('week').add(1, 'days').format('YYYY-MM-DD'),
                endOfWeek = moment(data.Date).endOf('week').add(1, 'days').format('YYYY-MM-DD');

            if (startOfWeek > data.Date) {
                startOfWeek = moment(data.Date).startOf('week').add(-6, 'days').format('YYYY-MM-DD');
                endOfWeek = moment(data.Date).endOf('week').add(-6, 'days').format('YYYY-MM-DD');
            }
            let key = startOfWeek + '~' + endOfWeek;

            let weekRangeDays = weekRangeDaysMap[key] ? weekRangeDaysMap[key] : [];
            data.taskId = this.selectedPT.Id;
            data.isBillable = this.selectedPT.Billable__c;
            data.locationId = this.selectedProject.Training_Location__c;
            data.status = 'Admin Approved';
            data = this.renameKeys(data, dayMapping);
            weekRangeDays.push(data);
            idsToRemove.push(data._id);
            weekRangeDaysMap[key] = weekRangeDays;
        }

        console.log(weekRangeDaysMap);
        this.save(weekRangeDaysMap, idsToRemove, true);
    }

    save(weekRangeDaysMap, idsToRemove, checkOnly) {
        this.loading = true;
        saveTimeEntries({
                projectId: this.selectedProject.Id,
                instructorId: this.selectedInstructor.Id,
                taskStr: JSON.stringify(this.selectedPT),
                weekRangeStrWithDayMapStr: JSON.stringify(weekRangeDaysMap),
                checkOnly: checkOnly
            })
            .then((result) => {
                this.loading = false;
                if (result == 'success') {
                    if (checkOnly) {
                        this.save(weekRangeDaysMap, idsToRemove, false);
                    } else {
                        this.showToast('Success', 'Time Entries are successfully saved!', 'success');
                        let _rows = [];
                        for (let row of JSON.parse(JSON.stringify(this._rows))) {
                            if (idsToRemove.indexOf(row._id) == -1) {
                                _rows.push(row);
                            }
                        }
                        this.template.querySelector('[data-id="tasklookup"]').handleRemove();
                        this._rows = _rows;
                        this.filteredData = [];
                        this.showTable = false;
                        this.weekRangeDaysMap = {};
                        this.idsToRemove = [];
                        this.toastMsg.show = false;
                    }
                } else if (result.indexOf('Time is already available for the following dates') != -1) {
                    this.weekRangeDaysMap = weekRangeDaysMap;
                    this.idsToRemove = idsToRemove;
                    this.showConfirm(result, 'Warning');
                } else {
                    this.showToast('Error', result, 'error');
                }
            })
            .catch((error) => {
                console.log('error::>', error);
                this.showToast('Error', error, 'error');
            });
    }

    confirmUpdate() {
        this.toastMsg.show = false;
        setTimeout((() => {
            this.save(this.weekRangeDaysMap, this.idsToRemove, false);
        }).bind(this), 0);

    }

    showConfirm(message, header) {
        this.toastMsg.show = true;
        this.toastMsg.message = message;
        this.toastMsg.header = header;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.filteredData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.filteredData = parseData;
    }

    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}