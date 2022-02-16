var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event) => {
    try {
            let dynamodb_table_name = process.env.dynamodb_table_name
            var obj = JSON.parse(event.body);
            var OPR = obj.operation;

            if (OPR == "write"){
                    var ID = obj.id;
                    var NAME = obj.name;
                    var params = {
                            TableName:dynamodb_table_name,
                            Item: {
                                    id : {S: ID},
                                    name : {S: NAME}
                            }
                    };
                    var data;
                    var msg;

                    try{
                            data = await ddb.putItem(params).promise();
                            console.log("Item entered successfully:", data);
                            msg = 'Item entered successfully';
                    } catch(err){
                            console.log("Error: ", err);
                            msg = err;
                    }

                    var response = {
                            'statusCode': 200,
                            'body': JSON.stringify({
                                    message: msg
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
