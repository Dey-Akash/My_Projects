@isTest
private class OpportunityTriggerHandlerTest
{

    @isTest
    static void testTaskCreatedWhenOppFlaggedStalled()
    {
        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Is_Stalled__c = false
        );
        insert opp;

        Test.startTest();
        opp.Is_Stalled__c = true;
        update opp;
        Test.stopTest();

        List<Task> tasks = [SELECT Subject, Priority FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(1, tasks.size());
        System.assertEquals('High', tasks[0].Priority);
        System.assert(tasks[0].Subject.contains('Test Deal'));
    }

    @isTest
    static void testNoTaskWhenAlreadyStalled() 
    {
        Opportunity opp = new Opportunity(
            Name = 'Already Stalled Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Is_Stalled__c = true
        );
        insert opp;

        Test.startTest();
        opp.Stall_Reason__c = 'Prospect on vacation';
        update opp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(0, tasks.size(),
            'No task should be created when Is_Stalled was already true');
    }

    @isTest
    static void testBulkStalledOpps() 
    {
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 0; i < 200; i++) 
        {
            opps.add(new Opportunity(
                Name = 'Bulk Deal ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Is_Stalled__c = false
            ));
        }
        insert opps;

        Test.startTest();
        for (Opportunity opp : opps) opp.Is_Stalled__c = true;
        update opps;
        Test.stopTest();

        Integer taskCount = [SELECT COUNT() FROM Task WHERE WhatId IN :opps];
        System.assertEquals(200, taskCount, 'Should bulkify to 200 tasks');
    }
}