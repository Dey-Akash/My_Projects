// Prints the enriched leads so the headline quality can be eyeballed.
List<Lead> leads = [SELECT Company, Industry, News_Mention_Count__c, News_Summary__c
                    FROM Lead WHERE CreatedDate = TODAY ORDER BY Company];

List<String> pending = new List<String>();
Integer shown = 0;
for (Lead l : leads) {
    Boolean failed = l.News_Summary__c == null || l.News_Summary__c.startsWith('Enrichment');
    if (failed) { pending.add(l.Company); continue; }
    if (shown < 12) {
        System.debug('OK | ' + l.Company + ' [' + l.Industry + '] ('
                     + l.News_Mention_Count__c + ') :: ' + l.News_Summary__c.left(150));
        shown++;
    }
}
System.debug('PENDING_COUNT=' + pending.size());
System.debug('PENDING=' + String.join(pending, ', '));
