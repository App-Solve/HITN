public class ReportCreator {
    @InvocableMethod(label='Create Report for Account')
    public static List<FlowOutput> createReportFromFlow(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        for (FlowInput input : inputs) {
            if (input.accountId == null) continue;

            Account acc = [SELECT Name FROM Account WHERE Id = :input.accountId LIMIT 1];
            String folderLabel = 'SP - ' + acc.Name;
            String folderDevName = ('SP_' + acc.Name).replaceAll('[^a-zA-Z0-9]', '_');

            String accessToken = OAuthHelper.getAccessToken();
            if (accessToken == null) {
                results.add(new FlowOutput('Failed to authenticate'));
                continue;
            }
            
            String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
            String metadataEndpoint = baseUrl + '/services/Soap/m/59.0';

            // Step 1: Create Folder
            String folderRequestBody = '<?xml version="1.0" encoding="utf-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                'xmlns:met="http://soap.sforce.com/2006/04/metadata" ' +
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<soapenv:Header>' +
                '<met:SessionHeader><met:sessionId>' + accessToken + '</met:sessionId></met:SessionHeader>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<met:createMetadata>' +
                '<met:metadata xsi:type="met:ReportFolder">' +
                '<met:fullName>' + folderDevName + '</met:fullName>' +
                '<met:name>' + folderLabel + '</met:name>' +
                '<met:accessType>Public</met:accessType>' +
                '</met:metadata>' +
                '</met:createMetadata>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';

            Http folderHttp = new Http();
            HttpRequest folderReq = new HttpRequest();
            folderReq.setEndpoint(metadataEndpoint);
            folderReq.setMethod('POST');
            folderReq.setHeader('Authorization', 'Bearer ' + accessToken);
            folderReq.setHeader('Content-Type', 'text/xml');
            folderReq.setHeader('SOAPAction', 'createMetadata');
            folderReq.setBody(folderRequestBody);
            folderHttp.send(folderReq);

            // Step 2: Create Report inside Folder
            String reportName = 'HITN Leads - ' + acc.Name;
            String reportDevName = ('HITN_Leads_' + acc.Name).replaceAll('[^a-zA-Z0-9]', '_');
            String reportRequestBody = '<?xml version="1.0" encoding="utf-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                'xmlns:met="http://soap.sforce.com/2006/04/metadata" ' +
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<soapenv:Header>' +
                '<met:SessionHeader><met:sessionId>' + accessToken + '</met:sessionId></met:SessionHeader>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<met:createMetadata>' +
                '<met:metadata xsi:type="met:Report">' +
                '<met:fullName>' + folderDevName + '/' + reportDevName + '</met:fullName>' +
                '<met:name>' + reportName + '</met:name>' +
                '<met:reportType>HITN_Leads__r</met:reportType>' + 
                '<met:format>Tabular</met:format>' +
                '<met:columns>HITN_Lead__c.Name</met:columns>' + 
                '<met:columns>HITN_Lead__c.Status__c</met:columns>' + 
                '<met:filter>' +
                '<met:criteriaItems>' +
                '<met:column>HITN_Lead__c.Account__c</met:column>' + //<!-- Field for Account lookup -->
                '<met:operator>equals</met:operator>' +
                '<met:value>' + acc.Name + '</met:value>' +
                '</met:criteriaItems>' +
                '</met:filter>' +
                '</met:metadata>' +
                '</met:createMetadata>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';

            Http reportHttp = new Http();
            HttpRequest reportReq = new HttpRequest();
            reportReq.setEndpoint(metadataEndpoint);
            reportReq.setMethod('POST');
            reportReq.setHeader('Authorization', 'Bearer ' + accessToken);
            reportReq.setHeader('Content-Type', 'text/xml');
            reportReq.setHeader('SOAPAction', 'createMetadata');
            reportReq.setBody(reportRequestBody);

            HttpResponse reportRes = reportHttp.send(reportReq);

            if (reportRes.getStatusCode() == 200) {
                results.add(new FlowOutput('Report created in folder: ' + folderLabel + '\nResponse: ' + reportRes.getBody()));
            } else {
                results.add(new FlowOutput('Failed to create report: ' + reportRes.getBody()));
            }
        }
        
        

        return results;
    }

    public class FlowInput {
        @InvocableVariable(required=true)
        public Id accountId;
    }

    public class FlowOutput {
        @InvocableVariable
        public String message;
        public FlowOutput(String msg) { message = msg; }
    }
}