global class StoreBatchUpdate implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Lead_Alert_Timer__c, Weekend_Alerts__c, Store_Time__c, Next_Business_Day_Start__c FROM Store__c');
    }

    global void execute(Database.BatchableContext BC, List<Store__c> storeList) {
        for (Store__c store : storeList) {
            // Increment Lead Alert Timer
            store.Lead_Alert_Timer__c = (store.Lead_Alert_Timer__c >= 8760) ? 1 : store.Lead_Alert_Timer__c + 1;

            // Calculate Next Business Day
            Date currentDate = Date.today();
            Date nextBusinessDay;
            Integer nextBusinessDayHours;

            if (store.Weekend_Alerts__c) {
                nextBusinessDay = currentDate.addDays(1);
                nextBusinessDayHours = 24;
            } else {
                Integer dayOfWeek = currentDate.toStartOfWeek().daysBetween(currentDate) + 1; // 1 = Monday, 7 = Sunday
                
                if (dayOfWeek == 5) { // Friday
                    nextBusinessDay = currentDate.addDays(2); // Move to Sunday
                } else if (dayOfWeek == 6) { // Saturday
                    nextBusinessDay = currentDate.addDays(1); // Move to Sunday
                } else {
                    nextBusinessDay = currentDate; // Weekday, stays the same
                }
                
                nextBusinessDayHours = nextBusinessDay.daysBetween(currentDate) * 24;
            }
			store.Store_Time__c = nextBusinessDayHours;
            store.Next_Business_Day_Start__c = nextBusinessDay;
        }
        update storeList;
    }
    global void finish(Database.BatchableContext BC) {}
}