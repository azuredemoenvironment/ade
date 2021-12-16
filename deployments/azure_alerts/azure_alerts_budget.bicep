// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The amount of the ADE Budget.')
param adeBudgetAmount int

@description('The name of the ADE Budget.')
param adeBudgetName string

@description('The first threshold of the ADE Budget.')
param adeBudgetFirstThreshold int

@description('The second threshold of the ADE Budget.')
param adeBudgetSecondThreshold int

@description('The third threshold of the ADE Budget.')
param adeBudgetThirdThreshold int

@description('The first threshold of the Forecasted ADE Budget.')
param adeBudgetFirstForecastedThreshold int

@description('The second threshold of the Forecasted ADE Budget.')
param adeBudgetSecondForecastedThreshold int

@description('The third threshold of the Forecasted ADE Budget.')
param adeBudgetThirdForecastedThreshold int

@description('The time grain of the ADE Budget.')
param adeBudgetTimeGrain string

@description('The ID of the Budget Action Group.')
param budgetActionGroupId string

@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

@description('Function to generate the current time.')
param currentTime string = utcNow('yyyy-MM-01')

// Variables
//////////////////////////////////////////////////
var adeBudgetStartDate = currentTime

// Resource - Budget Alert
//////////////////////////////////////////////////
resource adeBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: adeBudgetName
  properties: {
    timePeriod: {
      startDate: adeBudgetStartDate
    }
    timeGrain: adeBudgetTimeGrain
    amount: adeBudgetAmount
    category: 'Cost'
    notifications: {
      notificationForFirstThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetFirstThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
      notificationForSecondThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetSecondThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
      notificationForThirdThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetThirdThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
      notificationForFirstForecastedThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetFirstForecastedThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
      notificationForSecondForecastedThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetSecondForecastedThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
      notificationForThirdForecastedThreshold: {
        operator: 'GreaterThan'
        enabled: true
        threshold: adeBudgetThirdForecastedThreshold
        contactEmails: [
          contactEmailAddress
        ]
        contactGroups: [
          budgetActionGroupId
        ]
      }
    }
  }
}
