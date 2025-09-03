public class TestReportCreator {
    public static void createReport() {
        String accessToken = OAuthHelper.getAccessToken();
        if (accessToken == null) {
            System.debug('Failed to authenticate');
            return;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://your-instance.salesforce.com/services/Soap/m/59.0'); // Update API version
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', 'create');

        String requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                'xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
                '<soapenv:Header>' +
                '<met:SessionHeader>' +
                '<met:sessionId>' + accessToken + '</met:sessionId>' +
                '</met:SessionHeader>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<met:create>' +
                '<met:metadata xsi:type="met:Report">' +
                '<met:fullName>My_New_Report</met:fullName>' +
                '<met:reportType>Account.Standard</met:reportType>' +
                '<met:format>Tabular</met:format>' +
                '<met:columns>Account.Name</met:columns>' +
                '</met:metadata>' +
                '</met:create>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';

        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Response: ' + res.getBody());
    }
}