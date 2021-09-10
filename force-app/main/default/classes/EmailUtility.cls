public class EmailUtility {
	public static void toSendEmailWithTemplate(String Name, SObjectType objectType) {
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

		EmailTemplate emailTemp = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Decision_Maker'];

		try {
			sObject targetObject;
			if (objectType == Contact.SObjectType) {
				targetObject = [SELECT Id, Email FROM Contact WHERE LastName = :Name];
			} else if (objectType == User.SObjectType) {
				targetObject = [SELECT Id, Email FROM User WHERE LastName = :Name];
			}

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSaveAsActivity(false);
			mail.setTemplateId(emailTemp.Id);
			mail.setTargetObjectId(targetObject.Id);
			mailList.add(mail);

			if (!mailList.isEmpty())
				Messaging.sendEmail(mailList);
		} catch (QueryException qe) {
			System.debug('There is no contacts or opportunities with this lastname:' + qe.getMessage());
		} catch (EmailException ee) {
			System.debug('Email is invalid or not exist:' + ee.getMessage());
		}
	}
}
