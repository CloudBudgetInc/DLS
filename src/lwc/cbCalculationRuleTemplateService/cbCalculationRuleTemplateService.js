/**
Copyright (c) 02 2024, AJR, CloudBudget, Inc
All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
 * Neither the name of the CloudBudget, Inc. nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import {LightningElement, track} from 'lwc';
import getBudgetYearsServer from '@salesforce/apex/CBCalculationRuleGenerator.getBudgetYearsServer';
import generateCalculationRulesServer from '@salesforce/apex/CBCalculationRuleGenerator.generateCalculationRulesServer';
import runUpdatingInBatchForSelectedBudgetYearServer
	from '@salesforce/apex/CBCalculationRuleAllocationService.runUpdatingInBatchForSelectedBudgetYearServer';


export default class CBCalculationRuleTemplateService extends LightningElement {

	@track budgetYearId;
	@track showSpinner = false;
	@track generateButtonDisabled = true;
	@track budgetYears = [];

	async connectedCallback() {
		await this.getBudgetYears();
	}

	getBudgetYears = async () => {
		this.budgetYears = await getBudgetYearsServer().catch(e => alert('ERROR ' + e));
		this.budgetYears = this.budgetYears.map(by => ({value: by.Id, label: by.Name}));
	};

	handleChange = (event) => {
		this[event.target.name] = event.target.value;
		if (this.budgetYearId) this.generateButtonDisabled = false;
	};

	generateCalculationRules = async () => {
		this.showSpinner = true;
		let message;
		await generateCalculationRulesServer({byId: this.budgetYearId}).catch(e => message = e);
		this.showSpinner = false;
		this.generateButtonDisabled = true;
		if (message) console.error(message);
		message = message ? 'ERROR!' : 'DONE!';
		alert(message);
	};

	runUpdatingInBatchForSelectedBudgetYear = () => {
		if (!this.budgetYearId) {
			alert('First, choose a budget year');
			return null;
		}
		if (!confirm('Are you sure? This process will take some time')) {
			return null;
		}
		runUpdatingInBatchForSelectedBudgetYearServer({byId: this.budgetYearId})
			.then(() => alert('Process is started'))
			.catch(e => alert(e))
	}

}