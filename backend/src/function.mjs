import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  PutCommand,
  GetCommand,
  UpdateCommand,
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
    // console.log(event);

    let requestJSON;
    if (event.body) {
      requestJSON = JSON.parse(event.body);
    }

    if (event.routeKey.startsWith("POST /tasks") || event.routeKey.startsWith("GET /tasks") || event.routeKey.startsWith("PATCH /tasks")) {
      let userId = event?.queryStringParameters?.["user_id"];
      if (!userId) throw new Error("Bad request - missing 'user_id' query param");
    }

    switch (event.routeKey) {

      case "POST /tasks":

        var taskLabel = requestJSON["label"];
        if (!taskLabel) throw new Error("Bad request - missing 'label' in new Task");

        var taskWeight = requestJSON["weight"];
        if (!taskWeight) {
          taskWeight = 1.0
        }

        var currentTimestamp = Date.now();
        var taskId = asTaskId(userId, currentTimestamp);

        await dynamo.send(
          new PutCommand({
            TableName: tableName,
            Item: {
              pk: `USER_ID#${userId}`,
              sk: `TASK_CREATED_AT#${currentTimestamp}`,
              id: taskId,
              label: taskLabel,
              description: requestJSON.description,
              status: "TODO",
              weight: taskWeight,
            }
          })
        );

        responseBody = {
          "message": `Success! Created Task ${taskId}`
        }
        break;
      
      case "GET /tasks/{id}":
        var taskId = event.pathParameters.id;
        var taskCreatedAt = extractTaskCreatedAtFromTaskId(taskId);

        let getResponse = await dynamo.send(
          new GetCommand({
            TableName: tableName,
            Key: {
              pk: `USER_ID#${userId}`,
              sk: `TASK_CREATED_AT#${taskCreatedAt}`,
            },
          })
        );
        responseBody = getResponse.Item;
        break;

      case "GET /tasks/random":
        let queryResponse = await dynamo.send(
          new QueryCommand({ 
            TableName: tableName,
            KeyConditionExpression: "pk = :pkValue AND begins_with(sk, :skPrefix)",
            FilterExpression: "#status = :statusValue",
            // Necessary because 'status' is a reserved word
            ExpressionAttributeNames: {
              "#status": "status"
            },
            ExpressionAttributeValues: {
              ":pkValue": `USER_ID#${userId}`,
              ":skPrefix": "TASK_CREATED_AT#",
              ":statusValue": "TODO",
            },
          })
        );
        responseBody = selectTaskAtRandom(queryResponse.Items);
        break;
      
      case "GET /tasks":
        responseBody = await dynamo.send(
          new QueryCommand({ 
            TableName: tableName,
            KeyConditionExpression: "pk = :pkValue AND begins_with(sk, :skPrefix)",
            FilterExpression: "#status = :statusValue",
            // Necessary because 'status' is a reserved word
            ExpressionAttributeNames: {
              "#status": "status"
            },
            ExpressionAttributeValues: {
                ":pkValue": `USER_ID#${userId}`,
                ":skPrefix": "TASK_CREATED_AT#",
                ":statusValue": "TODO",
            },
          })
        );
        responseBody = responseBody.Items;
        break;
      
      case "PATCH /tasks/{id}":
        var taskId = event.pathParameters.id;
        var taskCreatedAt = extractTaskCreatedAtFromTaskId(taskId);
        
        // TODO Validate
        var updateExpressionParts = [];
        var ExpressionAttributeNames = {};
        var ExpressionAttributeValues = {};

        if (requestJSON.label) {
          updateExpressionParts.push("#label = :updatedLabel");
          ExpressionAttributeNames["#label"] = "label";
          ExpressionAttributeValues[":updatedLabel"] = requestJSON.label;
        }
        if (requestJSON.weight) {
          updateExpressionParts.push("#weight = :updatedWeight");
          ExpressionAttributeNames["#weight"] = "weight";
          ExpressionAttributeValues[":updatedWeight"] = requestJSON.weight;
        }
        if (requestJSON.status) {
          updateExpressionParts.push("#status = :updatedStatus");
          // Necessary because 'status' is a reserved word
          ExpressionAttributeNames["#status"] = "status";
          ExpressionAttributeValues[":updatedStatus"] = requestJSON.status
        }

        await dynamo.send(
          new UpdateCommand({
            TableName: tableName,
            Key: {
              pk: `USER_ID#${userId}`,
              sk: `TASK_CREATED_AT#${taskCreatedAt}`,
            },
            UpdateExpression: `SET ${updateExpressionParts.join(", ")}`,
            ExpressionAttributeNames,
            ExpressionAttributeValues,
            ConditionExpression: "attribute_exists(pk) AND attribute_exists(sk)", // Ensures "PATCH" rather than "UPSERT"
          })
        );
        responseBody = `Success! Updated task ${taskId}`
        break;
      
      case "POST /users/signin":
        var username = requestJSON["username"];
        if (!username) throw new Error("Bad request - missing 'username'");

        let userResponse = await dynamo.send(
          new QueryCommand({
            TableName: tableName,
            IndexName: "UsernameIndex",
            KeyConditionExpression: "username = :usernameValue",
            ExpressionAttributeValues: {
              ":usernameValue": username
            },
          })
        );

        if (userResponse.Items.length === 0) {
          throw new Error("User not found");
        }

        if (userResponse.Items.length > 1) {
          console.error(`Multiple users found with the username: ${username}`);
          throw new Error("Internal Server Error");
        }

        responseBody = userResponse.Items[0];
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

function asTaskId(userId, createdAtTimestamp) {
  return `${userId}-${createdAtTimestamp}`;
} 

function extractTaskCreatedAtFromTaskId(taskId) {
  var position = taskId.indexOf('-');
  return taskId.substring(position + 1);
}