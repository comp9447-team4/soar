# codebuild-notifier

Listens on an SNS topic that is integrated with our CodePipeline project.


This forwards any events from the pipeline to our Discord channel.

This is useful for events such as:
* successful builds
* failed builds
* failed builds due to critical vulnerabilities found