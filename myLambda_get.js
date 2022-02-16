var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event,context) => {
    try {

            let dynamodb_table_name = process.env.dynamodb_table_name
            console.log("EVENT queryStringParameters: \n" + JSON.stringify(event.queryStringParameters, null, 2))

            var OPR = event.queryStringParameters.operation;
            var ID = event.queryStringParameters.id;

            console.log (OPR)
            console.log (ID)
            if(OPR == "read"){

                    var params = {
                            TableName: dynamodb_table_name,
                            Key: {
                                    id : {S: ID}
                            }
                    };

                    var data;

                    try{
                            data = await ddb.getItem(params).promise();
                            console.log("Item read successfully:", data);
                    } catch(err){
                            console.log("Error: ", err);
                            data = err;
                    }

                    var response = {
                            'statusCode': 200,
                            'body': JSON.stringify({
                                    message: data
                            })
                    };
            }
            else{
                    var response = {
                            'statusCode': 200,
                            'body': JSON.stringify({
                                    message: "Invalid operation"
                            })
                    };
            }
    } catch (err) {
            console.log(err);
            return err;
    }

    return response;
};
