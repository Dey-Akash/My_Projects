trigger PassengerDetailsTriggerHandeler on Passenger_Details__c (before insert)
{
	if(Trigger.isBefore && Trigger.isInsert)
    {
        PassengerTriggerHandelerClass.ValidateEmail(Trigger.New);
        PassengerTriggerHandelerClass.ValidateMobile(Trigger.New);
    }
}