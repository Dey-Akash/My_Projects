trigger BookingTriggerHandeler on Booking__c (before insert)
{
	if(Trigger.IsInsert && Trigger.isBefore)
    {
        BookingTriggerHandelerClass.validetEmail(Trigger.New);
    }
}