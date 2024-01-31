import { LightningElement, api} from 'lwc';
import getPickListValues from '@salesforce/apex/ListViewController.getPickListValues'
import insertNewTask from '@salesforce/apex/CustomActivityTimelineController.insertTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NewTaskCmp extends LightningElement {
		
		taskData={};
		@api projectRecordId;
		statusOptions = {};
		isLoading = false;
		
		connectedCallback() {
			
			this.isLoading = true;			
			this.taskData.WhatId = this.projectRecordId;
			
			getPickListValues({sObjectName : 'Task', picklistName:'Status'})
			.then((result)=>{
				this.statusOptions = result;
				this.isLoading = false;
			}).catch((error)=>{
				console.log('error',error);
			})
		}
		
		handleChange(event) {
			this.taskData[event.target.name] = event.target.value;
		}
		
		handleRecordSelection(event) {
			
			this.selectedProject = { ...event.detail.selectedRecord };
			this.taskData[event.detail.fieldApiName] = this.selectedProject.Id;
		}
		handleCancel(){
			this.dispatchEvent(new CustomEvent('closefields',{detail : 
				{
					action : 'Cancel',
					object : 'Task'
				}
			}));
		}
		handleSave(){
			var isvalid = this.validate();
			if(isvalid) {
				var taskList = [];
				this.isLoading = true;
				taskList.push(this.taskData)
				
				insertNewTask({taskRecord : JSON.stringify(taskList)})
				.then((result)=>{
					
					this.dispatchEvent(new CustomEvent('closefields',{detail : 
                        {
                            action : 'Save',
                            object : 'Task'
                        }
                    }));
					this.isLoading = false;
					const event = new ShowToastEvent({
						title: 'Success',
						message: 'Task Record Created Successfully',
						variant: 'success',
						mode: 'dismissable'
					});
					this.dispatchEvent(event);
				}).catch((error)=>{
					console.log('error',error);
				})
			}
		}
		
		validate(){
			if(!this.taskData.Status || !this.taskData.OwnerId) {
				let statusField = this.template.querySelector('[data-id="Status"]');
				if (statusField.value == undefined || statusField.value == '') {
					statusField.checkValidity();
					statusField.reportValidity();
				}
				
				let ownerField = this.template.querySelector('[data-id="OwnerId"]').checkValidity();
				if(!ownerField) {
					this.template.querySelector('[data-id="OwnerId"]').reportValidity();
				}
				return false;
			}
			return true;
		}		
}