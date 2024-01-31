/** 
Copyright (c) 2022, CloudBudget, Inc.
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


public with sharing class CBTriggerService {

	public static Map<Id, Id> varDivisionMap {
		get {
			if (varDivisionMap == null) varDivisionMap = getVarDivisionMap();
			return varDivisionMap;
		}
		set;
	}
	public static Map<Id, String> accountMap {
		get {
			if (accountMap == null) accountMap = getAccountMap();
			return accountMap;
		}
		set;
	}
	public static Map<Id, String> var1Var2IdToNameMap {
		get {
			if (var1Var2IdToNameMap == null) var1Var2IdToNameMap = getVar1Var2IdToNameMap();
			return var1Var2IdToNameMap;
		}
		set;
	}

	/////// PRIVATE METHODS /////////
	private static List<cb5__CBVariable1__c> vars1 {
		get {
			if (vars1 == null) vars1 = [SELECT Id, Name, CBDivision__c FROM cb5__CBVariable1__c];
			return vars1;
		}
		set;
	}
	private static List<cb5__CBVariable2__c> vars2 {
		get {
			if (vars2 == null) vars2 = [SELECT Id, Name, CBDivision__c FROM cb5__CBVariable2__c];
			return vars2;
		}
		set;
	}
	private static Map<Id, Id> getVarDivisionMap() {
		Map<Id, Id> r = new Map<Id, Id>();
		for (cb5__CBVariable1__c v1 : vars1) r.put(v1.Id, v1.CBDivision__c);
		for (cb5__CBVariable2__c v2 : vars2) r.put(v2.Id, v2.CBDivision__c);
		return r;
	}
	private static Map<Id, String> getAccountMap() {
		Map<Id, String> r = new Map<Id, String>();
		for (cb5__CBAccount__c acc : [SELECT Id, Name FROM cb5__CBAccount__c]) r.put(acc.Id, acc.Name);
		return r;
	}
	private static Map<Id, String> getVar1Var2IdToNameMap() {
		Map<Id, String> r = new Map<Id, String>();
		for (cb5__CBVariable1__c v1 : vars1) r.put(v1.Id, v1.Name);
		for (cb5__CBVariable2__c v2 : vars2) r.put(v2.Id, v2.Name);
		return r;
	}
	/////// PRIVATE METHODS /////////

}