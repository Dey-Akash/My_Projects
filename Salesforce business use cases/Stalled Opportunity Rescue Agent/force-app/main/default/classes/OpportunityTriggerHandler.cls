public with sharing class OpportunityTriggerHandler 
{
    public static void handleAfterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap)
    {
        List<Task> tasksToCreate = new List<Task>();

        for (Opportunity opp : newList)
        {
            Opportunity oldOpp = oldMap.get(opp.Id);

            Boolean flippedToStalled = opp.Is_Stalled__c == true && oldOpp.Is_Stalled__c == false;

            if (flippedToStalled)
            {
                tasksToCreate.add(new Task(
                    WhatId = opp.Id,
                    OwnerId = opp.OwnerId,
                    Subject = 'Review stalled opportunity: ' + opp.Name,
                    Priority = 'High',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(1),
                    Description = 'This opportunity has had no activity for 14+ days. '
                                + 'Open the record and use the Rescue Agent to decide next steps.'
                ));
            }
        }

        if (!tasksToCreate.isEmpty()) insert tasksToCreate;
    }
}