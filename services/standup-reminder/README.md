# standup-reminder

I am a bot that pings the Discord channel to send their Stand Up updates!


# How to run local tests

```
IS_DEV=1 \
    PYTHONPATH=`pwd` \
    DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK=https://discordapp.com/api/webhooks/762644386009317407/R1qXCsrycsrTx6QFa-dgpyFbMjzFDhK2WnxQiqmQP-N07mID7Hs-bGYU0-ENb61v1d6G \
    pytest tests/unit/test_handler.py
```

# How to deploy
```
# Build
sam build

# Try to invoke it
sam local invoke

# Deploy
sam deploy
```
