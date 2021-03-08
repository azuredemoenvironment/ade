// Idea borrowed from https://medium.com/@SamPFacer/a-different-way-of-writing-gatling-scenarios-5d45168b6199
package ade

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.core.structure._

class AdeSimulation extends Simulation {
  // User Agents
  var userAgentString = "Gatling/3.5.1 (ADE.LoadTests)"

  // Standard Header Info for GET Requests
  val baseHeaders = Map(
    "Accept-Encoding" -> "gzip, deflate",
    "Accept-Language" -> "en-US,en;q=0.9",
    "Accept"          -> "*/*",
    "Cache-Control"   -> "no-cache",
    "Connection"      -> "keep-alive",
    "User-Agent"      -> userAgentString
  )

  // Test Run Configuration TODO: inject from Environment Variables
  val webFrontEndDomain   = "localhost:8080"
  val webFrontEndBaseUrl  = "http://" + webFrontEndDomain + "/"
  val webFrontEndHeaders  = baseHeaders + ("Host" -> webFrontEndDomain)
  val webFrontEndProtocol = http.baseUrl(webFrontEndDomain)

  val webBackEndDomain   = "localhost:8888"
  val webBackEndBaseUrl  = "http://" + webBackEndDomain + "/"
  val webBackEndHeaders  = baseHeaders + ("Host" -> webBackEndDomain)
  val webBackEndProtocol = http.baseUrl(webBackEndDomain)

  val scn = scenario("AdeSimulation")
    // Navigate to Home Page
    .exec(
      http("HomePage")
        .get(webFrontEndBaseUrl)
        .headers(webFrontEndHeaders)
        .check(status.is(200))
    )
    // Post Data to Data Entry
    .exec(
      http("DataPointsPost")
        .post(webBackEndBaseUrl + "DataPoints")
        .headers(webBackEndHeaders)
        .body(
          StringBody(
            """{ "booleanValue": true, "createdAt": "2021-03-08T15:24:34.627Z", "dataSource": "string", "decimalValue": 0, "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "integerValue": 0, "stringValue": "string", "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"}"""
          )
        )
        .asJson
        .check(status.is(200))
    )
    // Get Data
    .exec(
      http("DataPointsGet")
        .get(webBackEndBaseUrl + "DataPoints")
        .headers(webBackEndHeaders)
        .check(status.is(200))
    )

  // https://gatling.io/docs/current/general/simulation_setup/
  setUp(
    scn
      .inject(
        // atOnceUsers(5),
        // rampUsersPerSec(10).to(100).during(2.minutes)
        atOnceUsers(1)
      )
      .protocols(webFrontEndProtocol)
  ).assertions(
    // https://gatling.io/docs/3.2/general/assertions/
    global.responseTime.max.lt(100)
  )
}
