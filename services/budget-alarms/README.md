# budget-alarms

I am a bot that sends alarms if we are at 10, 20, 50, 80, 100% of our $100 budget.

## Local install

```
sam build
sam local invoke -e events/sns.json
```
