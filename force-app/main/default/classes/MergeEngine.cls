public class MergeEngine {

    private static final Pattern MERGE_FIELD_PATTERN = Pattern.compile('\\{!\\s*(Opportunity(?:\\.[a-zA-Z0-9_]+)+)\\s*\\}');

    public static String mergeOpportunityTemplate(String template, Id opportunityId) {
        if (String.isBlank(template) || opportunityId == null) return template;

        // Extract all merge fields from the template
        Set<String> mergeFields = new Set<String>();
        Matcher matcher = MERGE_FIELD_PATTERN.matcher(template);
        while (matcher.find()) {
            mergeFields.add(matcher.group(1)); // e.g., Opportunity.Account.Name
        }

        if (mergeFields.isEmpty()) return template;

        // Build dynamic SOQL fields list
        Set<String> fieldSet = new Set<String>();
        Map<String, String> mergeFieldToToken = new Map<String, String>();

        for (String path : mergeFields) {
            String token = '{! ' + path + ' }';
            mergeFieldToToken.put(path, token);

            // Strip "Opportunity." prefix
            String fieldPath = path.replaceFirst('Opportunity\\.', '');
            fieldSet.add(fieldPath);
        }

        // Query the Opportunity record with required fields
        String soql = 'SELECT ' + buildSelectClause(fieldSet) + ' FROM Opportunity WHERE Id = :opportunityId LIMIT 1';
        Opportunity opp = Database.query(soql);

        // Replace tokens with values
        String result = template;
        for (String path : mergeFields) {
            String fieldPath = path.replaceFirst('Opportunity\\.', '');
            Object value = resolveFieldPath(opp, fieldPath);
            result = result.replace(mergeFieldToToken.get(path), value != null ? String.valueOf(value) : '');
        }

        return result;
    }

    private static String buildSelectClause(Set<String> fieldPaths) {
        Set<String> rootFields = new Set<String>();
        Map<String, Set<String>> nestedFields = new Map<String, Set<String>>();

        for (String path : fieldPaths) {
            if (path.contains('.')) {
                String[] parts = path.split('\\.');
                String rel = parts[0];
                String field = parts[1];
                if (!nestedFields.containsKey(rel)) {
                    nestedFields.put(rel, new Set<String>());
                }
                nestedFields.get(rel).add(field);
            } else {
                rootFields.add(path);
            }
        }

        List<String> clauses = new List<String>();
        if (!rootFields.isEmpty()) clauses.addAll(rootFields);
        for (String rel : nestedFields.keySet()) {
            clauses.add(rel + '(' + String.join(new List<String>(nestedFields.get(rel)), ',') + ')');
        }

        return String.join(clauses, ', ');
    }

    private static Object resolveFieldPath(SObject record, String path) {
        String[] parts = path.split('\\.');
        SObject current = record;

        for (Integer i = 0; i < parts.size(); i++) {
            String field = parts[i];
            if (i == parts.size() - 1) {
                return current.get(field);
            } else {
                current = (SObject) current.getSObject(field);
                if (current == null) return null;
            }
        }
        return null;
    }
}
