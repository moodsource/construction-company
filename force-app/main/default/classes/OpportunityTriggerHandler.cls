public class OpportunityTriggerHandler implements ITriggerHandler {
	private static Boolean triggerDisabled = false;

	public void disableTrigger() {
		triggerDisabled = true;
	}
	public void enableTrigger() {
		triggerDisabled = false;
	}

	public Boolean isTriggerEnabled() {
		if (triggerDisabled) {
			return false;
		} else {
			return true;
		}
	}

	public void afterUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	) {
		List<Task> taskList = new List<Task>();
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

		Set<Id> parIds = new Set<Id>();
		Set<Id> wbsIds = new Set<Id>();
		Set<Id> userIds = new Set<Id>();
		for (Opportunity oppNew : (List<Opportunity>) newItems) {
			parIds.add(oppNew.Partner__c);
			wbsIds.add(oppNew.Work_Breakdown_Structure__c);
			userIds.add(oppNew.OwnerId);
		}

		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItemsMap;
		Map<Id, Partner__c> parMap = new Map<Id, Partner__c>(
			[SELECT Address__c, Name, Integration__c, id FROM Partner__c WHERE id IN :parIds]
		);
		Map<Id, Work_Breakdown_Structure__c> wbsMap = new Map<Id, Work_Breakdown_Structure__c>(
			[SELECT IsSynced__c, Status__c, id FROM Work_Breakdown_Structure__c WHERE id IN :wbsIds]
		);
		Map<Id, User> userMap = new Map<Id, User>([SELECT id, LastName FROM User WHERE id IN :userIds]);

		for (Opportunity oppNew : (List<Opportunity>) newItems) {
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
	}

	public void beforeUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	) {
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItemsMap;
		for (Opportunity oppNew : (List<Opportunity>) newItems) {
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

	public void beforeInsert(List<SObject> newItems) {
	}

	public void beforeDelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterDelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterUndelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterInsert(Map<Id, SObject> newItemsMap) {
	}
}
