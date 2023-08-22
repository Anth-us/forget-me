import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as ses from 'aws-cdk-lib/aws-ses';
import * as sesActions from 'aws-cdk-lib/aws-ses-actions';
import { Construct } from 'constructs';

export class ForgetMeStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Define the Lambda function
    const emailProcessorFunction = new lambda.Function(this, 'EmailProcessorFunction', {
      runtime: lambda.Runtime.RUBY_3_2,
      code: lambda.Code.fromAsset('lib'), // Replace with your directory path
      handler: 'lambda_function.lambda_handler',
    });

    // Set up a receipt rule to trigger the Lambda function for incoming emails
    const ruleSetName = 'MyRuleSet';
    const ruleSet = new ses.CfnReceiptRuleSet(this, 'RuleSet', {
      ruleSetName: ruleSetName,
    });

    new ses.CfnReceiptRule(this, 'MyRule', {
      ruleSetName: ruleSetName,
      rule: {
        name: 'MyRule',
        recipients: ['contact@yourdomain.com'],
        actions: [
          {
            lambdaAction: {
              functionArn: emailProcessorFunction.functionArn,
              invocationType: 'Event',
            },
          },
        ],
      },
    });
  }
}
