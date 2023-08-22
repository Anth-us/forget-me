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
                    'from' => ['sender@example.com'],
                    'to' => ['contact@yourdomain.com'],
                    'subject' => 'Forget Me Request',
                    'body' => <<-EMAIL
Dear Privacy Team,
...
Email: janedoe@example.com
...
                    EMAIL
                  }
                }
              }
            }
          ]
        }
      end

      it 'calls the forget function with the contact email' do
        expect_any_instance_of(Object).to receive(:forget).with({ "email" => "janedoe@example.com" })
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
