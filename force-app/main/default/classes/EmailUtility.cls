public class EmailUtility {
	public static Messaging.SingleEmailMessage putEmailInfoOnTemplate(String Name, SObjectType objectType) {
		EmailTemplate emailTemp = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Decision_Maker'];
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		try {
			sObject targetObject;
			if (objectType == Contact.SObjectType) {
				targetObject = [SELECT Id, Email FROM Contact WHERE LastName = :Name];
			} else if (objectType == User.SObjectType) {
				targetObject = [SELECT Id, Email FROM User WHERE LastName = :Name];
			}

			mail.setSaveAsActivity(false);
			mail.setTemplateId(emailTemp.Id);
			mail.setTargetObjectId(targetObject.Id);
		} catch (QueryException qe) {
			System.debug('There is no contacts or opportunities with this lastname:' + qe.getMessage());
		}
		return mail;
	}
	public static void sendEmail(List<Messaging.SingleEmailMessage> mailList) {
		if (!mailList.isEmpty()) {
			try {
				Messaging.sendEmail(mailList);
			} catch (EmailException ee) {
				System.debug('Email is invalid or doesn\'t exist:' + ee.getMessage());
			}
		}
	}
}
