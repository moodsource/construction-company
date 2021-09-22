trigger OpportunityTrigger on Opportunity(after update, before update) {
	if (Trigger.isAfter) {
		List<Task> taskList = new List<Task>();
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		Map<Id, Opportunity> oldMap = Trigger.oldMap;
		Map<Id, Partner__c> parMap = new Map<Id, Partner__c>(
			[SELECT Address__c, Name, Integration__c, id FROM Partner__c]
		);
		Map<Id, Work_Breakdown_Structure__c> wbsMap = new Map<Id, Work_Breakdown_Structure__c>(
			[SELECT IsSynced__c, Status__c, id FROM Work_Breakdown_Structure__c]
		);
		Map<Id, User> userMap = new Map<Id, User>([SELECT id, LastName FROM User]);
		for (Opportunity oppNew : Trigger.New) {
			Opportunity oppOld = oldMap.get(oppNew.Id);
			if (oppNew.StageName == 'Shared' && oppNew.Partner__c != null) {
				Partner__c par = parMap.get(oppNew.Partner__c);
				OpportunityCallout.postInfo(par.Address__c, par.Name, oppNew.Name, oppNew.Amount, oppNew.Type);
				par.Integration__c = true;
				update par;
			} else if (oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT) {
				if (oppNew.StageName != Constants.OPP_STAGE_NEW && oppNew.StageName != Constants.OPP_STAGE_CLOSED_WON) {
					Work_Breakdown_Structure__c wbs = wbsMap.get(oppNew.Work_Breakdown_Structure__c);
					User usr = userMap.get(oppNew.OwnerId);
					if (wbs.IsSynced__c) {
						wbs.Status__c = Constants.WBS_STATUS_REJECTED;
						update wbs;
					}
					taskList.add(new Task(Subject = 'Follow Up this Opportunity', WhatId = oppNew.Id));
					mailList.add(EmailUtility.putEmailInfoOnTemplate(usr.LastName, User.SObjectType));
				}
			}
		}
		EmailUtility.sendEmail(mailList);

		insert taskList;
	} else if (Trigger.isBefore) {
		Map<Id, Opportunity> oldMap = Trigger.oldMap;
		for (Opportunity oppNew : Trigger.New) {
			if (oppNew.StageName == Constants.OPP_STAGE_CLOSED_WON) {
				Opportunity oppOld = oldMap.get(oppNew.Id);
				if (
					oppOld.StageName != Constants.OPP_STAGE_NEGOTIATION &&
					oppOld.StageName != Constants.OPP_STAGE_QUOTE_SENT
				) {
					oppNew.addError('You can only change Quote Sent and Negotiation status on Closed Won.');
				}
			}
		}
	}
}
