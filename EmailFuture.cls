public class EmailFuture {
    public static void sendEmails(List<String> emailAddresses) {
        List<HITN_Lead__c> leads = [SELECT First_Name__c, Last_Name__c, Store__c, Service__c, Status__c, CreatedDate
                                    FROM HITN_Lead__c
                                    WHERE Status__c != 'Closed'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 100];

        String content = '<h2>Active Leads</h2><table border="1" cellpadding="5" cellspacing="0">'
                       + '<tr><th>Lead Name</th><th>Status</th><th>Created Date</th></tr>';

        for (HITN_Lead__c lead : leads) {
            String fullName = lead.First_Name__c + ' ' + lead.Last_Name__c;
            String status = lead.Status__c;
            String createdDate = String.valueOf(lead.CreatedDate.date());
            content += '<tr><td>' + fullName + '</td><td>' + status + '</td><td>' + createdDate + '</td></tr>';
        }

        content += '</table>';

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (String email : emailAddresses) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{email});
            mail.setSubject('Active Lead Report');
            mail.setHtmlBody(content);
            messages.add(mail);
        }

        Messaging.sendEmail(messages);
    }
}