// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The properties of the  Budget.')
param budgetProperties object

// Resource - Budget Alert
//////////////////////////////////////////////////
resource adeBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetProperties.name
  properties: {
    timePeriod: {
      startDate: budgetProperties.startDate
    }
    timeGrain: budgetProperties.timeGrain
    amount: budgetProperties.amount
    category: budgetProperties.category
    notifications: {
      notificationForFirstThreshold: {
        operator: budgetProperties.operator
        enabled: budgetProperties.enabled
        threshold: budgetProperties.firstThreshold
        contactEmails: [
          budgetProperties.contactEmails
        ]
        contactGroups: [
          budgetProperties.contactGroups
        ]
      }
      notificationForSecondThreshold: {
        operator: budgetProperties.operator
        enabled: budgetProperties.enabled
        threshold: budgetProperties.secondThreshold
        contactEmails: [
          budgetProperties.contactEmails
        ]
        contactGroups: [
          budgetProperties.contactGroups
        ]
      }
      notificationForThirdThreshold: {
        operator: budgetProperties.operator
        enabled: budgetProperties.enabled
        threshold: budgetProperties.thirdThreshold
        contactEmails: [
          budgetProperties.contactEmails
        ]
        contactGroups: [
          budgetProperties.contactGroups
        ]
      }
      notificationForFirstForecastedThreshold: {
        operator: budgetProperties.operator
        enabled: budgetProperties.enabled
        threshold: budgetProperties.forecastedThreshold
        contactEmails: [
          budgetProperties.contactEmails
        ]
        contactGroups: [
          budgetProperties.contactGroups
        ]
      }
    }
  }
}
