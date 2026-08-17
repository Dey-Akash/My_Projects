// Re-runs news enrichment against the new (real) company names.
//
// The "Lead News Enrichment on Create" flow only fires on insert, so after a company
// rename the leads must be re-enqueued by hand.
//
// Pass 1 (CLEAR = true)  : nulls out the stale news fields on all of today's leads.
// Pass 2..n (CLEAR = false): enqueues enrichment for up to BATCH_LIMIT leads whose
//                            News_Summary__c is still null. Repeat until DONE.
//
// BATCH_LIMIT stays under the Apex ceiling of 50 queueable jobs per transaction.

// NewsAPI rate-limits bursts: firing 40 queueables at once returns HTTP 429 on most of
// them. Keep BATCH_LIMIT small and run the script repeatedly instead.
Boolean CLEAR = false;
Integer BATCH_LIMIT = 10;

// News_Summary__c is a long text area, so it cannot be filtered in SOQL --
// query today's leads and branch in Apex instead.
List<Lead> leads = [SELECT Id, Company, News_Summary__c
                    FROM Lead WHERE CreatedDate = TODAY ORDER BY Company];

if (CLEAR) {
    List<Lead> cleared = new List<Lead>();
    for (Lead l : leads) {
        cleared.add(new Lead(Id = l.Id, News_Summary__c = null,
                             News_Mention_Count__c = null, Last_News_Date__c = null));
    }
    update cleared;
    System.debug('CLEARED=' + cleared.size());
} else {
    Integer queued = 0, remaining = 0;
    for (Lead l : leads) {
        // Retry blanks AND previous failures ("Enrichment failed: HTTP 429" etc.)
        Boolean needsWork = l.News_Summary__c == null
                            || l.News_Summary__c.startsWith('Enrichment');
        if (!needsWork) continue;
        if (queued < BATCH_LIMIT) {
            System.enqueueJob(new LeadNewsEnrichmentQueueable(l.Id, l.Company));
            queued++;
        } else {
            remaining++;
        }
    }
    System.debug('QUEUED=' + queued + ' STILL_PENDING_AFTER_THIS_RUN=' + remaining);
    if (queued == 0) System.debug('DONE - every lead has a news summary');
}
