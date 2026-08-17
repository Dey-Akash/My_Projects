public with sharing class PrioritizeLeadsAction {

    // Keyword sets for rule-based scoring
    private static final Set<String> HOT_KEYWORDS = new Set<String>{
        'funding', 'raised', 'series a', 'series b', 'series c', 'series d',
        'series e', 'series f', 'ipo', 'acquisition', 'acquires', 'expansion',
        'expand', 'expanding', 'launch', 'launches', 'launched', 'partnership',
        'partner', 'record revenue', 'record profit', 'growth', 'hiring',
        'new plant', 'new facility'
    };
    private static final Set<String> COLD_KEYWORDS = new Set<String>{
        'layoff', 'layoffs', 'job cut', 'job cuts', 'workforce reduction',
        'losses', 'loss widens', 'shutdown', 'shut down', 'bankruptcy',
        'restructuring', 'declined', 'cost cut', 'freeze', 'downsizing',
        'plant closure'
    };

    // What the agent action returns to the agent
    public class Request {
        @InvocableVariable(
            label='Time window'
            description='TODAY, YESTERDAY, or THIS_WEEK. Defaults to TODAY.'
        )
        public String timeWindow;
    }
    public class Result {
        @InvocableVariable public String summary;
        @InvocableVariable public Integer totalPrioritized;
        @InvocableVariable public Integer hotCount;
        @InvocableVariable public Integer warmCount;
        @InvocableVariable public Integer coldCount;
        @InvocableVariable public Integer skippedCount;
    }

    @InvocableMethod(
        label='Prioritize Leads'
        description='Scores today\u2019s (or another window\u2019s) leads Hot/Warm/Cold based on news enrichment. Updates Priority_Verdict__c and Priority_Reason__c on each Lead.'
    )
    public static List<Result> prioritize(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            String windowValue = String.isBlank(req.timeWindow) ? 'TODAY' : req.timeWindow.toUpperCase();

            // Build the SOQL date filter safely (no string concat with user input)
            String dateFilter;
            if (windowValue == 'YESTERDAY') dateFilter = 'YESTERDAY';
            else if (windowValue == 'THIS_WEEK') dateFilter = 'THIS_WEEK';
            else dateFilter = 'TODAY';

            // Query candidate leads.
            // News_Summary__c is a long text area, which SOQL cannot filter on. The
            // enrichment job always writes News_Mention_Count__c alongside the summary,
            // so it is a filterable stand-in for "this lead has been enriched".
            String soql = 'SELECT Id, Company, News_Summary__c '
                        + 'FROM Lead '
                        + 'WHERE CreatedDate = ' + dateFilter + ' '
                        + 'AND News_Mention_Count__c != null '
                        + 'LIMIT 200';
            List<Lead> leads = Database.query(soql);

            Integer hot = 0, warm = 0, cold = 0, skipped = 0;
            List<Lead> toUpdate = new List<Lead>();

            for (Lead ld : leads) {
                String verdict;
                String reason;

                // A failed callout ("Enrichment failed: HTTP 429") carries no signal
                // about the lead. Scoring it Cold would misreport a quota problem as
                // a disinterested prospect, so leave the verdict untouched.
                if (ld.News_Summary__c != null
                    && (ld.News_Summary__c.startsWith('Enrichment failed')
                        || ld.News_Summary__c.startsWith('Enrichment error'))) {
                    skipped++;
                    continue;
                }

                // Split the enriched news summary back into headlines
                List<String> headlines = ld.News_Summary__c == null
                    ? new List<String>()
                    : ld.News_Summary__c.split(' \\| ');

                Integer hotHits = 0, coldHits = 0;
                String hotEvidence = null, coldEvidence = null;

                for (String headline : headlines) {
                    String lower = headline.toLowerCase();
                    for (String kw : HOT_KEYWORDS) {
                        if (lower.contains(kw)) {
                            hotHits++;
                            if (hotEvidence == null) hotEvidence = headline;
                            break;
                        }
                    }
                    for (String kw : COLD_KEYWORDS) {
                        if (lower.contains(kw)) {
                            coldHits++;
                            if (coldEvidence == null) coldEvidence = headline;
                            break;
                        }
                    }
                }

                // These strings must match the Priority_Verdict__c picklist exactly
                // (Hot / Warm / Cold) or the update throws on a restricted picklist.
                if (headlines.isEmpty() || (hotHits == 0 && coldHits == 0 && headlines.size() < 2)) {
                    verdict = 'Cold';
                    reason = 'Little to no news activity.';
                    cold++;
                } else if (hotHits > coldHits && hotHits > 0) {
                    verdict = 'Hot';
                    reason = ('Positive signal: "' + hotEvidence + '"').left(255);
                    hot++;
                } else if (coldHits > hotHits && coldHits > 0) {
                    verdict = 'Cold';
                    reason = ('Negative signal: "' + coldEvidence + '"').left(255);
                    cold++;
                } else {
                    verdict = 'Warm';
                    reason = ('Neutral activity. ' + headlines.size() + ' recent mentions.').left(255);
                    warm++;
                }

                toUpdate.add(new Lead(
                    Id = ld.Id,
                    Priority_Verdict__c = verdict,
                    Priority_Reason__c = reason
                ));
            }

            if (!toUpdate.isEmpty()) update toUpdate;

            Result r = new Result();
            r.totalPrioritized = toUpdate.size();
            r.hotCount = hot;
            r.warmCount = warm;
            r.coldCount = cold;
            r.skippedCount = skipped;
            r.summary = 'Prioritized ' + toUpdate.size() + ' leads from ' + windowValue.toLowerCase()
                      + '. Breakdown: ' + hot + ' Hot, ' + warm + ' Warm, ' + cold + ' Cold. '
                      + (skipped > 0
                          ? skipped + ' skipped because news enrichment had failed for them. '
                          : '')
                      + 'Open the "Today\u2019s Prioritized Leads" list view to see them.';
            results.add(r);
        }
        return results;
    }
}