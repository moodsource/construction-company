trigger ChangeOnQuoteSentStage on Opportunity (After update) {
    List<Task> taskList = new List<Task>(); 
    for(Opportunity oppOld : Trigger.Old) {
        if(oppOld.StageName == 'Quote Sent')
        {
            for(Opportunity oppNew : Trigger.New) {
                if(oppNew.StageName != 'New' && oppNew.StageName != 'Closed Won')
                {
                    Work_Breakdown_Structure__c wbs = [SELECT IsSynced__c, Status__c FROM Work_Breakdown_Structure__c WHERE Opportunity__c =:oppNew.id];
                    User usr = [SELECT id, LastName FROM User WHERE id =:oppNew.OwnerId];
                    if(wbs.IsSynced__c == True)
                    {
                        wbs.Status__c = 'Rejected';
                        update wbs;
                    }
                    taskList.add(new Task (Subject = 'Follow Up this Opportunity', WhatId = oppNew.Id)); 
                    EmailUtility.toSendEmailWithTemplate(usr.LastName, 'User');
                }
            }
        }
    }
  insert taskList;
}