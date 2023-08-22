require 'net/http'
require 'json'
require 'aws-sdk-lambda'
require 'logger'; $logger = Logger.new(STDOUT)

# Load environment variables from .env file in development.
require 'dotenv'
Dotenv.load

def lambda_handler(event:, context:)
  email_content = extract_email_content(event)

  # Construct the message for OpenAI with function signature
  messages = [
    { "role" => "system", "content" => "You are a virtual assistant tasked with identifying and processing 'forget-me' requests from emails. Determine if the email content contains such a request and if so, call the 'forget' function with the appropriate arguments." },
    { "role" => "user", "content" => email_content }
  ]
  functions = [
    {
      "name" => "forget",
      "description" => "Forget the user's data",
      "parameters" => {
        "type" => "object",
        "properties" => {
          "email" => { "type" => "string", "description" => "User's email address" },
          "phone" => { "type" => "string", "description" => "User's phone number" }
        }
      }
    }
  ]

  uri = URI('https://api.openai.com/v1/chat/completions')
  request = Net::HTTP::Post.new(uri, {
    'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}",
    'Content-Type' => 'application/json'
  })
  request.body = {
    model: "gpt-3.5-turbo-0613",
    messages: messages,
    functions: functions,
    temperature: 0.2,
    top_p: 0.5,
    max_tokens: 150, # Adjust as needed
    frequency_penalty: 0.5,
    presence_penalty: 0.0,
    n: 3 # Request 3 completions
  }.to_json

  $logger.info("Calling OpenAI with request:\n" +
    JSON.pretty_generate(JSON.parse(request.body)))

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  response_body = JSON.parse(response.body)
  $logger.info("Received response from OpenAI:\n" +
    JSON.pretty_generate(response_body))

  # Check if any of the choices call the forget function
  if response_body['choices'].any? {|choice|
      choice.dig('message', 'function_call', 'name') == 'forget'
    }

    # Call the forget function with the arguments from the first
    # one that does call the function.
    function_call = response_body['choices'].find {|choice|
      choice.dig('message', 'function_call', 'name') == 'forget'
    }['message']['function_call']

    args = JSON.parse(function_call['arguments'])

    forget(args)
  end    

  { statusCode: 200, body: 'Processed' }
end

def forget(args)
  # Implement your business logic here based on the arguments provided
end

def extract_email_content(event)
  (
    'Subject: ' +
      event['Records'][0]['Ses']['Mail']['commonHeaders']['subject'] +
    "\n\n" +
    event['Records'][0]['Ses']['Mail']['commonHeaders']['body']
  )
end
