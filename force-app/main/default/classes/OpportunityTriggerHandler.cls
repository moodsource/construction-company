public class OpportunityTriggerHandler extends AbstractTriggerHandler {
	public override void afterUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		checkOppStageAndSendEmail(newItemsMap, oldItemsMap);
	}

	public override void beforeUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		addErrorIfStageIsInvalid(newItemsMap, oldItemsMap);
	}

	private void checkOppStageAndSendEmail(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		Set<Id> parIds = new Set<Id>();
		for (Opportunity oppNew : (List<Opportunity>) newItemsMap.values()) {
			parIds.add(oppNew.Partner__c);
		}

		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItemsMap;
		Map<Id, Partner__c> parMap = new Map<Id, Partner__c>(
			[SELECT Address__c, Name, Integration__c, id FROM Partner__c WHERE id IN :parIds]
		);

		for (Opportunity oppNew : (List<Opportunity>) newItemsMap.values()) {
			Opportunity oppOld = oldMap.get(oppNew.Id);
			if (oppNew.StageName == 'Shared' && oppNew.Partner__c != null) {
				Partner__c par = parMap.get(oppNew.Partner__c);
				OpportunityCallout.postInfo(par.Address__c, par.Name, oppNew.Name, oppNew.Amount, oppNew.Type);
				par.Integration__c = true;
				update par;
			} else if (
				(oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT) &&
				(oppNew.StageName != Constants.OPP_STAGE_NEW &&
				oppNew.StageName != Constants.OPP_STAGE_CLOSED_WON)
			) {
				sendEmailToDecisionMakerAndAddTasks(newItemsMap, oldItemsMap);
			}
		}
	}

	private void sendEmailToDecisionMakerAndAddTasks(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		List<Task> taskList = new List<Task>();
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

		Set<Id> wbsIds = new Set<Id>();
		Set<Id> userIds = new Set<Id>();

		for (Opportunity oppNew : (List<Opportunity>) newItemsMap.values()) {
			wbsIds.add(oppNew.Work_Breakdown_Structure__c);
			userIds.add(oppNew.OwnerId);
		}

		Map<Id, User> userMap = new Map<Id, User>([SELECT id, LastName FROM User WHERE id IN :userIds]);
		Map<Id, Work_Breakdown_Structure__c> wbsMap = new Map<Id, Work_Breakdown_Structure__c>(
			[SELECT IsSynced__c, Status__c, id FROM Work_Breakdown_Structure__c WHERE id IN :wbsIds]
		);

		for (Opportunity oppNew : (List<Opportunity>) newItemsMap.values()) {
			Work_Breakdown_Structure__c wbs = wbsMap.get(oppNew.Work_Breakdown_Structure__c);
			User usr = userMap.get(oppNew.OwnerId);
			if (wbs.IsSynced__c) {
				wbs.Status__c = Constants.WBS_STATUS_REJECTED;
				update wbs;
			}
			taskList.add(new Task(Subject = 'Follow Up this Opportunity', WhatId = oppNew.Id));
			mailList.add(EmailUtility.putEmailInfoOnTemplate(usr.LastName, User.SObjectType));
		}

		EmailUtility.sendEmail(mailList);
		insert taskList;
	}

	private void addErrorIfStageIsInvalid(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItemsMap;
		for (Opportunity oppNew : (List<Opportunity>) newItemsMap.values()) {
			Opportunity oppOld = oldMap.get(oppNew.Id);
			if (
				(oppNew.StageName == Constants.OPP_STAGE_CLOSED_WON) &&
				(oppOld.StageName != Constants.OPP_STAGE_NEGOTIATION &&
				oppOld.StageName != Constants.OPP_STAGE_QUOTE_SENT)
			) {
				oppNew.addError('You can only change Quote Sent and Negotiation status on Closed Won.');
			}
		}
	}
}
