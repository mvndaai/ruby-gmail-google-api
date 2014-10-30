#NOTES
# API Testing: https://developers.google.com/apis-explorer/#p/gmail/v1/
# Email Query: https://support.google.com/mail/answer/7190?hl=en
# gem install google-api-client
# make sure it is not using the gem retriable-2.0.0.beta5

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'json'

END{
  client, gmail = setup
  #list_labels(client,gmail)
  #find_emails(client,gmail,'')
}

CREDENTIAL_STORE_FILE = "oauth2.json"
API_VERSION = 'v1'
MAX_SEARCH_AMOUNT = <max # of emails returned>
EMAIL = <email address of account>


def base64_url_decode(str)
   str += '=' * (4 - str.length.modulo(4))
   Base64.decode64(str.tr('-_','+/'))
 end

def setup()
  client = Google::APIClient.new(:application_name => 'Gmail API',
    :application_version => '0.1.0')

  #Read client_secrets.json
  client_secrets = Google::APIClient::ClientSecrets.load

  # FileStorage stores auth credentials in a file, so they survive multiple runs
  # of the application. This avoids prompting the user for authorization every
  # time the access token expires, by remembering the refresh token.
  # Note: FileStorage is not suitable for multi-user applications.
  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  if file_storage.authorization.nil?
    #client_secrets = Google::APIClient::ClientSecrets.load
    # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
    # application flow, which ties in with FileStorage to store credentials
    # between runs.
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => client_secrets.client_id,
      :client_secret => client_secrets.client_secret,
      :scope => ['https://www.googleapis.com/auth/gmail.readonly',
                'https://www.googleapis.com/auth/gmail.modify',
                'https://www.googleapis.com/auth/gmail.compose',
                'https://mail.google.com/']
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end
  gmail = client.discovered_api('gmail',API_VERSION)
  return client, gmail
end


def list_labels(client,gmail)
  result = client.execute(
    :api_method => gmail.users.labels.list,
    :parameters => {'userId' => EMAIL}
    )

  if result.data?
    return result.data.labels
  end
end

def find_emails(client,gmail,search_string='')
  result = client.execute(
    :api_method => gmail.users.messages.list,
    :parameters => {'userId' => EMAIL,
      'includeSpamTrash' => true,
      'maxResults' => MAX_SEARCH_AMOUNT,
      'q' => search_string
      }
    )

    if result.data?
      puts "found = #{result.data.messages.length}"
      result.data.messages.each do |message|
        get_email_by_id(client,gmail,message.id)
      end
    end
end

def get_email_by_id(client,gmail,id)
  result = client.execute(
    :api_method => gmail.users.messages.get,
    :parameters => {'userId' => EMAIL,'id' => id})

  if result.data?
    email = new Hash
    puts "ID: #{id}"

    result.data.payload.headers.each do |header|
      email[:subject] = header.value}" if header.name == 'Subject' 
      email[:to] = header.value}" if header.name == 'To' 
      email[:from] = header.value}" if header.name == 'From' 
    end
    puts "Snippet: #{result.data.snippet}"
    if (result.data.payload.parts.length == 0)
      body = result.data.payload.to_hash['body']['data']
    else
      body = result.data.payload.parts.first.to_hash['body']['data']
    end
    email[:body] = base64_url_decode(body)
    return email
  end
end

