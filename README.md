ruby-gmail-google-api
=====================

This is a ruby implementation of the google api to access gmail.

Pre Setup
-----------------------
1. Create a google developer project - https://console.developers.google.com/project
2. Enable 'Gmail API' under 'APIs & Auth' > 'APIs'
3. Click 'Create new  Client ID' under 'APIs & Auth' > 'Credentials'
4. Chose 'Installed Application'
5. Click 'Download as JSON', the rename the file to just 'client_secret.json'
6. Put the 'client_secret.json' file in the path

Notes
-----
* If you do not want to have a separate file for your client_secret.json replace   
  `client_secrets = Google::APIClient::ClientSecrets.load`   
  with   
  `client_secrets = Google::APIClient::ClientSecrets.new (MultiJson.load('<contents of client_secret.json>'))`
* The reason I don't share my client is because I don't want to push the [limits set by google](https://developers.google.com/gmail/api/v1/reference/quota)
