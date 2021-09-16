trigger OpportunityTrigger on Opportunity(after update, before update) {
	if (Trigger.isAfter) {
		List<Task> taskList = new List<Task>();
		Map<Id, Opportunity> oldMap = Trigger.oldMap;
		for (Opportunity oppNew : Trigger.New) {
			Opportunity oppOld = oldMap.get(oppNew.Id);
			if (oppNew.StageName == 'Shared' && oppNew.Partner__c != null) {
				Partner__c par = [
					SELECT Address__c, Name, Integration__c
					FROM Partner__c
					WHERE id = :oppNew.Partner__c
				];
				OpportunityCallout.postInfo(par.Address__c, par.Name, oppNew.Name, oppNew.Amount, oppNew.Type);
				par.Integration__c = true;
				update par;
			} else if (oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT) {
				if (oppNew.StageName != Constants.OPP_STAGE_NEW && oppNew.StageName != Constants.OPP_STAGE_CLOSED_WON) {
					Work_Breakdown_Structure__c wbs = [
						SELECT IsSynced__c, Status__c
						FROM Work_Breakdown_Structure__c
						WHERE Opportunity__c = :oppNew.id
					];
					User usr = [SELECT id, LastName FROM User WHERE id = :oppNew.OwnerId];
					if (wbs.IsSynced__c) {
						wbs.Status__c = Constants.WBS_STATUS_REJECTED;
						update wbs;
					}
					taskList.add(new Task(Subject = 'Follow Up this Opportunity', WhatId = oppNew.Id));
					EmailUtility.toSendEmailWithTemplate(usr.LastName, User.SObjectType);
				}
			}
		}
		insert taskList;
	} else if (Trigger.isBefore) {
		Map<Id, Opportunity> oldMap = Trigger.oldMap;
		for (Opportunity oppNew : Trigger.New) {
			if (oppNew.StageName == Constants.OPP_STAGE_CLOSED_WON) {
				Opportunity oppOld = oldMap.get(oppNew.Id);
				if (
					oppOld.StageName == Constants.OPP_STAGE_NEGOTIATION ||
					oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT
				) {
					oppNew.addError('You cannot change Quote Sent and Negotiation status on Closed Won.');
				}
			}
		}
	}
}
