// Parameters
//////////////////////////////////////////////////
@description('The amount of the ADE Budget.')
param adeBudgetAmount int

@description('The first threshold of the ADE Budget.')
param adeBudgetFirstThreshold int

@description('The name of the ADE Budget.')
param adeBudgetName string

@description('The second threshold of the ADE Budget.')
param adeBudgetSecondThreshold int

@description('The start date of the ADE Budget.')
param adeBudgetStartDate string

@description('The third threshold of the ADE Budget.')
param adeBudgetThirdThreshold int

@description('The time grain of the ADE Budget.')
param adeBudgetTimeGrain string

@description('The ID of the Budget Action Group.')
param budgetActionGroupId string

@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

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
    }
  }
}
