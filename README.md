# api_gateway_lambda_dynamodb

AWS api gateway api key can be found on aws console. use api key to access api gateway.

[ec2-user@ip-192-168-20-103 api_gateway_lambda_dynamodb]$ curl -X POST -H "x-api-key:xxxxxx" -d '{"operation":"write","id":"12","name":"test12"}' https://xxxxxx.execute-api.us-east-1.amazonaws.com/Prod/myresource
{"message":"Item entered successfully"}


[ec2-user@ip-192-168-20-103 api_gateway_lambda_dynamodb]$  curl  -H "x-api-key:xxxxxxxx" "https://xxxxxx.execute-api.us-east-1.amazonaws.com/Prod/myresource?operation=read&id=12"
{"message":{"Item":{"id":{"S":"12"},"name":{"S":"test12"}}}}

