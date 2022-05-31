## Monitoring failures

This folder is a simple jenkins setup to monitor liveliness of any service.

> **Note**: For each server we'd need to create new pipelines on the jenkins server by
using different paramters for the server we'd like to test and the test spec we'd like
to run. This way we just need to add more test specs. Testing code will stay the same.


#### Jenkins setup:

1. Create a pipeline in your jenkins repo (if you have an existing pipeline created, you can use the duplicate pipeline feature of jenkins to do minimal setup)

   1. In new item create a Pipeline project
     ![image](https://user-images.githubusercontent.com/45075777/139317879-6a1e2685-ed05-41a8-a1e2-8e8973dbf91a.png)

   2. Add the needed parameters by checking add parameters:
      1. server_to_test : server that the test spec will be executed against
      2. test_spec : the file in monitoring/test-spec defining tests to run
      3. email_recipients: comma separated emails to notify when monitoring fails
   ![image](https://user-images.githubusercontent.com/45075777/139318721-749e1c04-0613-4979-9660-8c24f5451a1d.png)

   3. Add build trigger
    ![image](https://user-images.githubusercontent.com/45075777/139319614-2f155e98-6ec5-4f00-b46c-eeff0e074bbe.png)

   4. Point pipeline defination to Jenkins file in the repo
    ![image](https://user-images.githubusercontent.com/45075777/139319827-cd1a969c-e040-4c93-a7b0-e9840f92052d.png)


#### Test spec

The testing tool used here is [artillery.io](https://artillery.io/docs/guides/overview/welcome.html) with the [expect-plugin](https://artillery.io/docs/guides/plugins/plugin-expectations-assertions.html).
As such the test specs are artillery test specs.

## Running Locally

You can run the monitoring scripts locally with this command:

```
docker run -it --entrypoint=ash \
    -v=$PWD:/home/jenkins/workspace/ \
    --workdir=/home/jenkins/workspace/ \
    renciorg/artillery:2.0.0-5-expect-plugin
    ./run_tests.sh
```
