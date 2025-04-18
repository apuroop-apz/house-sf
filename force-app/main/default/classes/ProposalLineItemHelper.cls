public with sharing class ProposalLineItemHelper {
    public static void swapSortOrder(List<Proposal_Line_Item__c> oldList, List<Proposal_Line_Item__c> newList){
        if (ProposalLineItemTriggerState.isSortOrderRunning) return;
        ProposalLineItemTriggerState.isSortOrderRunning = true;

        try {
            Set<Id> proposalItemIds = new Set<Id>();
            Map<Id, Integer> oldPLIMap = new Map<Id, Integer>();
            Map<Id, Integer> newPLIMap = new Map<Id, Integer>();
            List<Proposal_Line_Item__c> recordsToUpdate = new List<Proposal_Line_Item__c>();

            for(Proposal_Line_Item__c newPLI : newList) {
                proposalItemIds.add(newPLI.Proposal_Item__c);
                if (newPLI.Sort_Order__c != null) {
                    newPLIMap.put((Id)newPLI.Id, (Integer)newPLI.Sort_Order__c);
                }
            }
            for(Proposal_Line_Item__c oldPLI : oldList) {
                if (oldPLI.Sort_Order__c != null) {
                    oldPLIMap.put((Id)oldPLI.Id, (Integer)oldPLI.Sort_Order__c);
                }
            }
            // Query all the Proposal_Line_Item__c records related to the affected Proposal_Item__c records
            List<Proposal_Line_Item__c> allProposalLineItems = [
                SELECT Id, Proposal_Item__c, Sort_Order__c 
                FROM Proposal_Line_Item__c 
                WHERE Proposal_Item__c IN :proposalItemIds AND Id NOT IN :newPLIMap.keySet()
                ORDER BY Proposal_Item__c, Sort_Order__c ASC
            ];
            
            for(Proposal_Line_Item__c existing : allProposalLineItems) {
                for(Proposal_Line_Item__c updated : newList) {
                    if(
                        existing.Proposal_Item__c == updated.Proposal_Item__c && 
                        existing.Sort_Order__c == updated.Sort_Order__c && 
                        existing.Id != updated.Id
                    ){
                        existing.Sort_Order__c = oldPLIMap.get(updated.Id);
                        recordsToUpdate.add(existing);
                    }
                }
            }
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }catch (Exception e) {
            System.debug('Sort Order Swap Error: ' + e.getMessage());
        } finally {
            ProposalLineItemTriggerState.isSortOrderRunning = false;
        }
    }

    public static void assignSortOrderBeforeInsert(List<Proposal_Line_Item__c> newItems) {
        Set<Id> parentIds = new Set<Id>();
        for (Proposal_Line_Item__c pli : newItems) {
            if (pli.Proposal_Item__c != null) {
                parentIds.add(pli.Proposal_Item__c);
            }
        }
    
        // Query max sort order for each Proposal_Item__c
        Map<Id, Integer> maxSortMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Proposal_Item__c, MAX(Sort_Order__c) maxSort
            FROM Proposal_Line_Item__c
            WHERE Proposal_Item__c IN :parentIds
            GROUP BY Proposal_Item__c
        ]) {
            maxSortMap.put((Id)ar.get('Proposal_Item__c'), Integer.valueOf(ar.get('maxSort')));
        }
    
        // Assign next sort order
        Map<Id, Integer> nextSortMap = new Map<Id, Integer>();
        for (Proposal_Line_Item__c pli : newItems) {
            Id parentId = pli.Proposal_Item__c;
            Integer current = nextSortMap.containsKey(parentId) ? nextSortMap.get(parentId) : (maxSortMap.get(parentId) != null ? maxSortMap.get(parentId) : 0);
            current++;
            pli.Sort_Order__c = current;
            nextSortMap.put(parentId, current);
        }
    }
/*
    public static void assignDefaultSortOrder(List<Proposal_Line_Item__c> lineItems, Set<Id> proposalItemIds) {
        System.debug('START: assignDefaultSortOrder');
        if (lineItems.isEmpty() || proposalItemIds.isEmpty()) return;

        Set<Id> inputIds = new Set<Id>(); // To track records in Trigger.new
        for (Proposal_Line_Item__c pli : lineItems) {
            if (pli.Id != null) {
                inputIds.add(pli.Id); // Track the IDs of the records being processed
            }
        }

        // Get all existing siblings grouped by parent
        Map<Id, List<Proposal_Line_Item__c>> existingByParent = new Map<Id, List<Proposal_Line_Item__c>>();
        for (Proposal_Line_Item__c item : [
            SELECT Id, Proposal_Item__c, Sort_Order__c
            FROM Proposal_Line_Item__c
            WHERE Proposal_Item__c IN :proposalItemIds 
            AND Id NOT IN :inputIds
            ORDER BY Proposal_Item__c, Sort_Order__c ASC
        ]) {
            if (!existingByParent.containsKey(item.Proposal_Item__c)) {
                existingByParent.put(item.Proposal_Item__c, new List<Proposal_Line_Item__c>());
            }
            existingByParent.get(item.Proposal_Item__c).add(item);
        }
        System.debug('Existing line items by parent: ' + existingByParent);
        System.debug('existingByParent Size: ' + existingByParent.size());

        // Assign default sort order
        for (Proposal_Line_Item__c pli : lineItems) {
            System.debug('Processing line item pli: ' + pli);
            if (pli.Sort_Order__c != null || pli.Proposal_Item__c == null) continue;
            System.debug('Reached after continue');
            List<Proposal_Line_Item__c> existing = existingByParent.get(pli.Proposal_Item__c);
            Integer max = 0;
            // Recalculate Sort_Order__c for each item in order
            for (Integer i = 0; i < existing.size(); i++) {
                Proposal_Line_Item__c e = existing[i];
                if (e.Sort_Order__c != null) {
                    max = Integer.valueOf(Math.max(max, e.Sort_Order__c));
                }
                e.Sort_Order__c = i + 1; // Reindex from 1
            }
            pli.Sort_Order__c = max + 1;
            // Add this new item to the existing list for future inserts in same batch
            if (!existingByParent.containsKey(pli.Proposal_Item__c)) {
                existingByParent.put(pli.Proposal_Item__c, new List<Proposal_Line_Item__c>());
            }
            existingByParent.get(pli.Proposal_Item__c).add(pli);
        }
        System.debug('END: assignDefaultSortOrder');
    }

    public static void reindexSortOrder(Map<Id, List<Proposal_Line_Item__c>> itemsByParent) {
        for (Id parentId : itemsByParent.keySet()) {
            List<Proposal_Line_Item__c> siblings = itemsByParent.get(parentId);
            Integer sort = 1;
            for (Proposal_Line_Item__c item : siblings) {
                item.Sort_Order__c = sort;
                sort++;
            }
        }
    }*/

    
    public static void assignDefaultSortOrder(List<Proposal_Line_Item__c> newItems, Set<Id> proposalItemIds) {
        if (newItems.isEmpty() || proposalItemIds.isEmpty()) return;

        Map<Id, List<Proposal_Line_Item__c>> allByParent = new Map<Id, List<Proposal_Line_Item__c>>();

        // Load existing siblings
        List<Proposal_Line_Item__c> existing = [
            SELECT Id, Proposal_Item__c, Sort_Order__c
            FROM Proposal_Line_Item__c
            WHERE Proposal_Item__c IN :proposalItemIds
            ORDER BY Proposal_Item__c, Sort_Order__c ASC
        ];

        // Add existing siblings to the map
        for (Proposal_Line_Item__c item : existing) {
            if (!allByParent.containsKey(item.Proposal_Item__c)) {
                allByParent.put(item.Proposal_Item__c, new List<Proposal_Line_Item__c>());
            }
            allByParent.get(item.Proposal_Item__c).add(item);
        }

        // Add new incoming records with blank sort order
        for (Proposal_Line_Item__c item : newItems) {
            if (item.Sort_Order__c != null || item.Proposal_Item__c == null) continue;

            if (!allByParent.containsKey(item.Proposal_Item__c)) {
                allByParent.put(item.Proposal_Item__c, new List<Proposal_Line_Item__c>());
            }
            allByParent.get(item.Proposal_Item__c).add(item);
        }

        // Delegate to shared reindexing method
        reindexSortOrder(allByParent);
    }

    public static void reindexSortOrder(Map<Id, List<Proposal_Line_Item__c>> itemsByParent) {
        for (Id parentId : itemsByParent.keySet()) {
            List<Proposal_Line_Item__c> siblings = itemsByParent.get(parentId);
            Integer currentSort = 1;
            for (Proposal_Line_Item__c item : siblings) {
                item.Sort_Order__c = currentSort;
                currentSort++;
            }
        }
    }
    
}