trigger WorkBreakdownTrigger on Work_Breakdown_Structure__c(before update, after update) {
	if (Trigger.isBefore) {
		for (Work_Breakdown_Structure__c wbs : Trigger.New) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				wbs.IsSynced__c = true;
			}
		}
	} else if (Trigger.isAfter) {
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		for (Work_Breakdown_Structure__c wbs : Trigger.New) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				Opportunity opp = [
					SELECT Amount, Decision_Maker__r.LastName, id
					FROM Opportunity
					WHERE Id = :wbs.Opportunity__c
					LIMIT 1
				];
				opp.Amount = wbs.Total_Amount__c;
				opp.Work_Breakdown_Structure__c = wbs.Id;
				update opp;
				mailList.add(EmailUtility.putEmailInfoOnTemplate(opp.Decision_Maker__r.LastName, Contact.SObjectType));
			}
		}
		EmailUtility.sendEmail(mailList);
	}
}
