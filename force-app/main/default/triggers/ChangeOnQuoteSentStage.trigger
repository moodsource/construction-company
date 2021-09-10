trigger ChangeOnQuoteSentStage on Opportunity(after update) {
	List<Task> taskList = new List<Task>();
	Map<Id, Opportunity> oldMap = Trigger.oldMap;
	for (Opportunity oppNew : Trigger.New) {
		Opportunity oppOld = oldMap.get(oppNew.Id);
		if (oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT) {
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
}
