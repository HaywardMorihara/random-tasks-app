import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  PutCommand,
  GetCommand,
} from "@aws-sdk/lib-dynamodb";

import { selectTaskAtRandom } from "./random.mjs";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "random-tasks";

export const handler = async (event, context) => {
  let responseBody;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
  };

  try {
    // DEBUG
    // console.log(event)

    let requestJSON
    if (event.body) {
      requestJSON = JSON.parse(event.body);
    }
    
    let userId = event?.queryStringParameters?.["user_id"]
    if (!userId) throw new Error("Bad request - missing 'user_id' query param");

    switch (event.routeKey) {

      case "POST /tasks":

        var taskLabel = requestJSON["label"];
        if (!taskLabel) throw new Error("Bad request - missing 'label' in new Task");

        var currentTimestamp = Date.now();
        var taskId = `${userId}$#${currentTimestamp}`

        await dynamo.send(
          new PutCommand({
            TableName: tableName,
            Item: {
              pk: `USER_ID#${userId}`,
              sk: `TASK_CREATED_AT#${currentTimestamp}`,
              id: taskId,
              label: taskLabel,
              description: requestJSON.description,
              status: "TODO"
            }
          })
        );

        responseBody = {
          "message": `Success! Created Task ${taskId}`
        }
        break;
      case "GET /tasks/random":
        // TODO
        let queryResponse = await dynamo.send(
          new QueryCommand({ 
            TableName: tableName,
            KeyConditionExpression: "pk = :pkValue",
            ExpressionAttributeValues: {
                ":pkValue": `USER_ID#${userId}`,
            },
          })
        );
        responseBody = selectTaskAtRandom(queryResponse.Items);
        break;
      case "GET /tasks":
        console.log("here");
        responseBody = await dynamo.send(
          new QueryCommand({ 
            TableName: tableName,
            KeyConditionExpression: "pk = :pkValue",
            ExpressionAttributeValues: {
                ":pkValue": `USER_ID#${userId}`,
            },
          })
        );
        responseBody = responseBody.Items;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    responseBody = err.message;
  } finally {
    responseBody = JSON.stringify(responseBody);
  }

  return {
    statusCode,
    body: responseBody,
    headers,
  }; 
};