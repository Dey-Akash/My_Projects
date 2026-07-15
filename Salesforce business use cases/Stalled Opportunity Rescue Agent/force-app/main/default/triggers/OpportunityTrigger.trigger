trigger OpportunityTrigger on Opportunity (After Update) 
{
    OpportunityTriggerHandler.handleAfterUpdate(Trigger.New,Trigger.oldMap);
}