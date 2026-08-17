// Runs the Prioritize Leads agent action against today's leads.
PrioritizeLeadsAction.Request req = new PrioritizeLeadsAction.Request();
req.timeWindow = 'TODAY';

List<PrioritizeLeadsAction.Result> results =
    PrioritizeLeadsAction.prioritize(new List<PrioritizeLeadsAction.Request>{ req });

PrioritizeLeadsAction.Result r = results[0];
System.debug('RESULT total=' + r.totalPrioritized + ' hot=' + r.hotCount
             + ' warm=' + r.warmCount + ' cold=' + r.coldCount
             + ' skipped=' + r.skippedCount);
System.debug('SUMMARY ' + r.summary);

for (Lead l : [SELECT Company, Priority_Verdict__c, Priority_Reason__c
               FROM Lead
               WHERE CreatedDate = TODAY AND Priority_Verdict__c = 'Hot'
               ORDER BY Company LIMIT 8]) {
    System.debug('HOT ' + l.Company + ' :: ' + l.Priority_Reason__c);
}
