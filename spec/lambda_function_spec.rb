# spec/lambda_function_spec.rb
require_relative '../lib/lambda_function'
require 'json'

describe 'LambdaFunction' do
  describe '.lambda_handler' do
    let(:context) { {} } # Mock AWS Lambda context object if needed

    context 'when the email is a forget-me request' do
      let(:event) do
        {
          'Records' => [
            {
              'Ses' => {
                'Mail' => {
                  'commonHeaders' => {
                    'from' => ['janedoe@example.com'],
                    'to' => ['contact@yourdomain.com'],
                    'subject' => 'Forget Me Request',
                    'body' => <<~EMAIL
                      Dear Privacy Team,
                      I’m asking several companies to delete the data they hold on me. To make this easy for me to manage, and in line with the ICO guidance, please don’t ask me to perform a self service process or fill out a form.
                      I would like to exercise my right of erasure under data protection law. If there’s any information that can’t be deleted for regulatory reasons please confirm what needs to be retained and minimise what you can. (Eg. Marketing and third party data processing).
                      To help find my account in your records, my details are:
                      Name: Jane Doe
                      Email: janedoe@example.com
                      Please send email confirmation once the process has been completed and if you need any more information, please let me know.
                      Thank you in advance.
                    EMAIL
                  }
                }
              }
            }
          ]
        }
      end

      it 'calls the forget function with the contact email' do
        expect_any_instance_of(Object).to receive(:forget).
          with({ "email" => "janedoe@example.com", "name"=>"Jane Doe" })
        lambda_handler(event: event, context: context)
      end
    end

    context 'when the email also contains a phone number' do
      let(:event) do
        {
          'Records' => [
            {
              'Ses' => {
                'Mail' => {
                  'commonHeaders' => {
                    'from' => ['janedoe@example.com'],
                    'to' => ['contact@yourdomain.com'],
                    'subject' => 'Forget Me Request',
                    'body' => <<~EMAIL
                      Dear Privacy Team,
                      I’m asking several companies to delete the data they hold on me. To make this easy for me to manage, and in line with the ICO guidance, please don’t ask me to perform a self service process or fill out a form.
                      I would like to exercise my right of erasure under data protection law. If there’s any information that can’t be deleted for regulatory reasons please confirm what needs to be retained and minimise what you can. (Eg. Marketing and third party data processing).
                      To help find my account in your records, my details are:
                      Name: Jane Doe
                      Email: janedoe@example.com
                      Phone: 555 555 5555
                      Please send email confirmation once the process has been completed and if you need any more information, please let me know.
                      Thank you in advance.
                    EMAIL
                  }
                }
              }
            }
          ]
        }
      end

      it 'calls the forget function with the contact email and phone number' do
        expect_any_instance_of(Object).to receive(:forget).
          with({
            "email" => "janedoe@example.com",
            "name"=>"Jane Doe",
            "phone"=> "555 555 5555"
          })
        lambda_handler(event: event, context: context)
      end
    end

    context 'when the email is random spam' do
      let(:event) do
        {
          'Records' => [
            {
              'Ses' => {
                'Mail' => {
                  'commonHeaders' => {
                    'from' => ['spammer@example.com'],
                    'to' => ['contact@yourdomain.com'],
                    'subject' => 'You won a million dollars!',
                    'body' => 'Click here to claim your prize!'
                  }
                }
              }
            }
          ]
        }
      end

      it 'does not call the forget function' do
        expect_any_instance_of(Object).not_to receive(:forget)
        lambda_handler(event: event, context: context)
      end
    end
  end
end
