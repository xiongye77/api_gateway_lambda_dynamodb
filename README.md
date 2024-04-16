# api_gateway_lambda_dynamodb


![image](https://user-images.githubusercontent.com/36766101/156271319-fc60b961-7fa5-4dd3-a7dc-6e35e98a8a8a.png)


A stage is a named reference to a deployment, which is a snapshot of the API. You use a Stage to manage and optimize a particular deployment. For example, you can configure stage settings to enable caching, customize request throttling, configure logging, define stage variables, or attach a canary release for testing.

![image](https://user-images.githubusercontent.com/36766101/156286132-43c46e1d-be06-4195-907b-4d77a59b9e30.png)

AWS api gateway api key can be found on aws console when you click show button. use api key to access api gateway.

[ec2-user@ip-192-168-20-103 api_gateway_lambda_dynamodb]$ curl -X POST -H "x-api-key:xxxxxx" -d '{"operation":"write","id":"12","name":"test12"}' https://xxxxxx.execute-api.us-east-1.amazonaws.com/Prod/myresource


{"message":"Item entered successfully"}


[ec2-user@ip-192-168-20-103 api_gateway_lambda_dynamodb]$  curl  -H "x-api-key:xxxxxxxx" "https://xxxxxx.execute-api.us-east-1.amazonaws.com/Prod/myresource?operation=read&id=12"


{"message":{"Item":{"id":{"S":"12"},"name":{"S":"test12"}}}}



![image](https://user-images.githubusercontent.com/36766101/154180283-baa6b3f9-a16b-43b0-b4f3-325a2d13372a.png)



![image](https://github.com/xiongye77/api_gateway_lambda_dynamodb/assets/36766101/bca75d4a-1341-4ce5-a518-454a413918cb)
aws cloudformation create-stack \
    --stack-name apigw-lambda-sm \
    --template-body file://cloudformation.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey=AuthorizationTokenValue,ParameterValue="token_value" \
    --region ap-southeast-2 \
    --disable-rollback

curl -X GET -H "Authorization: $APIGW_TOKEN" https://api_id.execute-api.eu-central-1.amazonaws.com/dev/invoke
"Simple Main lambda function responce"

 curl -X GET -H "Authorization: INCORRECT_TOKEN" https://api_id.execute-api.eu-central-1.amazonaws.com/dev/invoke
{"message":"Forbidden"}
