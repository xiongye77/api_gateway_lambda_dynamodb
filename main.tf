provider "aws" {
   region = "ap-southeast-2"
}

resource "aws_dynamodb_table" "ddbtable" {
  name             = var.dynamodb_table_name
  hash_key         = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.role_for_LDC.id

  policy = file("policy.json")
}


resource "aws_iam_role" "role_for_LDC" {
  name = "myrole"

  assume_role_policy = file("assume_role_policy.json")

}


resource "aws_lambda_function" "myLambda_post" {
  filename         = "myLambda_post.zip"
  function_name = "myLambda_post"
  role          = aws_iam_role.role_for_LDC.arn
  handler       = "myLambda_post.handler"
  runtime       = "nodejs14.x"
  environment {
    variables = {
      dynamodb_table_name = var.dynamodb_table_name
    }
  }

}



resource "aws_lambda_function" "myLambda_get" {
  filename         = "myLambda_get.zip"
  function_name = "myLambda_get"
  role          = aws_iam_role.role_for_LDC.arn
  handler       = "myLambda_get.handler"
  runtime       = "nodejs14.x"
  environment {
    variables = {
      dynamodb_table_name = var.dynamodb_table_name
    }
  }

}



resource "aws_api_gateway_rest_api" "apiLambda" {
  name        = "myAPI"

}


resource "aws_api_gateway_resource" "Resource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "myresource"

}


resource "aws_api_gateway_method" "Method_post" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.Resource.id
   http_method   = "POST"
   authorization = "NONE"
   api_key_required = true
}


resource "aws_api_gateway_method" "Method_get" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.Resource.id
   http_method   = "GET"
   authorization = "NONE"
   api_key_required = true
}

resource "aws_api_gateway_integration" "lambdaInt_post" {
   depends_on = [
    aws_lambda_permission.apigw_post
   ]
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.Resource.id
   http_method = aws_api_gateway_method.Method_post.http_method
   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.myLambda_post.invoke_arn

}


resource "aws_api_gateway_integration" "lambdaInt_get" {
   depends_on = [
    aws_lambda_permission.apigw_get
   ]
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.Resource.id
   http_method = aws_api_gateway_method.Method_get.http_method
   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.myLambda_get.invoke_arn

}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name = "Prod"
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  deployment_id = aws_api_gateway_deployment.apideploy.id
}

resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [aws_api_gateway_integration.lambdaInt_post,aws_api_gateway_integration.lambdaInt_get]
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   #stage_name  = "Prod"
}


resource "aws_lambda_permission" "apigw_get" {
   statement_id  = "AllowExecutionFromAPIGateway_get"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.myLambda_get.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "arn:aws:execute-api:us-east-1:996104769930:${aws_api_gateway_rest_api.apiLambda.id}/*/${aws_api_gateway_method.Method_get.http_method}${aws_api_gateway_resource.Resource.pa
th}"
}



resource "aws_lambda_permission" "apigw_post" {
   statement_id  = "AllowExecutionFromAPIGateway_post"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.myLambda_post.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "arn:aws:execute-api:us-east-1:996104769930:${aws_api_gateway_rest_api.apiLambda.id}/*/${aws_api_gateway_method.Method_post.http_method}${aws_api_gateway_resource.Resource.p
ath}"
}



resource "aws_api_gateway_usage_plan" "apigw_usage_plan" {
  name = "apigw_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.apiLambda.id
    stage = aws_api_gateway_stage.prod_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "apigw_usage_plan_key" {
  key_id = aws_api_gateway_api_key.apigw_prod_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.apigw_usage_plan.id
}

resource "aws_api_gateway_api_key" "apigw_prod_key" {
  name = "prod_key"
}

data "archive_file" "myLambda_post" {
    type          = "zip"
    source_file   = "myLambda_post.js"
    output_path   = "myLambda_post.zip"
}


data "archive_file" "myLambda_get" {
    type          = "zip"
    source_file   = "myLambda_get.js"
    output_path   = "myLambda_get.zip"
}
output "base_url" {
  value = "${aws_api_gateway_deployment.apideploy.invoke_url}${aws_api_gateway_stage.prod_stage.stage_name}/${aws_api_gateway_resource.Resource.path_part}"
}

