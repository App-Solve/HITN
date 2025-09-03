public class OAuthHelper {
    public static String getAccessToken() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://test.salesforce.com/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String clientId = '3MVG91HPV4v4AB8YNiDUR_G5X0DgG_IUb89dDwvxyxuEdlQm7BPxH8pz1eYoSUt9Tk4pV8yb62rhayMZymbBr';
        String clientSecret = '9F66C3EFF4E63264CAFBF7A2E207DA04AD5355F4CADD114FB574B89F45D348C3';
        String username = 'client@appsolve.com';
        String password = 'Toronto2';

        String requestBody = 'grant_type=password' +
                             '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                             '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                             '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
                             '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');

        req.setBody(requestBody);

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String accessToken = (String) result.get('access_token');
                System.debug('Access token retrieved successfully');
                return accessToken;
            } else {
                System.debug('Failed to get access token. Status: ' + res.getStatus());
                System.debug('Response Body: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception while getting access token: ' + e.getMessage());
        }

        return null;
    }
}