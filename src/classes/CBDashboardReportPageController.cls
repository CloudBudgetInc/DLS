/** 
Copyright (c) 2024, CloudBudget, Inc.
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


public with sharing class CBDashboardReportPageController {

	private static List<cb5__CBPeriod__c> sortedPeriods {
		get {
			if (sortedPeriods == null) {
				sortedPeriods = [SELECT Id,cb5__CBBudgetYear__c,Name FROM cb5__CBPeriod__c ORDER BY cb5__Start__c LIMIT 5000];
			}
			return sortedPeriods;
		}
		set;
	}

	@AuraEnabled
	public static List<cb5__CBPeriod__c> getPeriodsServer() {
		return sortedPeriods;
	}

	@AuraEnabled
	public static List<cb5__CBCube__c> getCBCubesForPeriodServer(String startPeriodId, String endPeriodId) {
		Set<String> neededPeriods = getSetOfAllNeededPeriods(startPeriodId, endPeriodId);
		return [
				SELECT Id, cb5__DrillDownIds__c,cb5__CBAccount__c,cb5__CBDivision__c,cb5__Actual__c,cb5__Budget__c,cb5__CBAccount__r.Name,
						cb5__CBAccount__r.cb5__CBAccountType__r.Name, CBAccountSubtype2__c,cb5__CBDivision__r.Name,
						cb5__CBVariable2__r.Name
				FROM cb5__CBCube__c
				WHERE cb5__CBPeriod__c IN:neededPeriods AND cb5__CBAccount__r.cb5__CBAccountType__r.Name != null AND cb5__CBDivision__r.Name != null
				ORDER BY cb5__CBAccount__r.Name
				LIMIT 48000
		];
	}

	private static Set<String> getSetOfAllNeededPeriods(String startPeriodId, String endPeriodId) {
		if (endPeriodId == null) return new Set<String>{
				startPeriodId
		};
		Set<String> r = new Set<String>();
		Boolean isNeededPeriod = false;
		for (cb5__CBPeriod__c p : sortedPeriods) {
			if (startPeriodId == p.Id) isNeededPeriod = true;
			if (isNeededPeriod) r.add(p.Id);
			if (endPeriodId == p.Id) break;
		}
		return r;
	}

}