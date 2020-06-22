//
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/config;
import ballerina/log;
import ballerina/test;

string testBucketName = config:getAsString("BUCKET_NAME");

ClientConfiguration amazonS3Config = {
    accessKeyId: config:getAsString("ACCESS_KEY_ID"),
    secretAccessKey: config:getAsString("SECRET_ACCESS_KEY"),
    region: config:getAsString("REGION")
};

@test:Config{}
function testCreateBucket() {
    log:printInfo("amazonS3Client->createBucket()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        CannedACL cannedACL = ACL_PRIVATE;
        ConnectorError? response = amazonS3Client->createBucket(testBucketName, cannedACL);
        if (response is ConnectorError) {
            test:assertFail(response.message());
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testCreateBucket"]
}
function testListBuckets() {
    log:printInfo("amazonS3Client->listBuckets()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        ConnectorError|Bucket[] response = amazonS3Client->listBuckets();
        if (response is ConnectorError) {
            test:assertFail(response.message());
        } else {
            string bucketName = response[0].name;
            test:assertTrue(bucketName.length() > 0, msg = "Failed to call listBuckets()");
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testListBuckets"]
}
function testCreateObject() {
    log:printInfo("amazonS3Client->createObject()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        ConnectorError? response = amazonS3Client->createObject(testBucketName, "test.txt","Sample content");
        if (response is ConnectorError) {
            test:assertFail(response.message());
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testCreateObject"]
}
function testGetObject() {
    log:printInfo("amazonS3Client->getObject()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        S3Object|ConnectorError response = amazonS3Client->getObject(testBucketName, "test.txt");
        if (response is S3Object) {
            byte[]? content = response["content"];
        } else {
            test:assertFail(response.message());
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testGetObject"]
}
function testListObjects() {
    log:printInfo("amazonS3Client->listObjects()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        S3Object[]|ConnectorError response = amazonS3Client -> listObjects(testBucketName, fetchOwner = true);
        if (response is ConnectorError) {
            test:assertFail(response.message());
        } else {
            test:assertTrue(response.length() > 0, msg = "Failed to call listObjects()");
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testListObjects"]
}
function testDeleteObject() {
    log:printInfo("amazonS3Client -> deleteObject()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        ConnectorError? response = amazonS3Client -> deleteObject(testBucketName, "test.txt");
        if (response is ConnectorError) {
            test:assertFail(response.message());
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}

@test:Config {
    dependsOn: ["testDeleteObject"]
}
function testDeleteBucket() {
    log:printInfo("amazonS3Client -> deleteBucket()");
    AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        ConnectorError? response = amazonS3Client -> deleteBucket(testBucketName);
        if (response is ConnectorError) {
            test:assertFail(response.message());
        }
    } else {
        test:assertFail(amazonS3Client.message());
    }
}
