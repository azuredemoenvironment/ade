// Idea borrowed from https://medium.com/@SamPFacer/a-different-way-of-writing-gatling-scenarios-5d45168b6199
package ade

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.core.structure._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.redis.Predef._
import com.redis._

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

  // Value Generation
  val redisPool      = new RedisClientPool("localhost", 6379)
  val wordListFeeder = redisFeeder(redisPool, "DATA")

  // Scenario Steps
  val navigateToHomePage = http("HomePage")
    .get(webFrontEndBaseUrl)
    .headers(webFrontEndHeaders)
    .check(status.is(200))

  val postDataToApi = http("DataPointsPost")
    .post(webBackEndBaseUrl + "DataPoints")
    .headers(webBackEndHeaders)
    .body(
      StringBody(
        """{ "booleanValue": ${verified}, "decimalValue": ${overall}, "integerValue": ${unixReviewTime}, "stringValue": "${reviewerName}"}"""
      )
    )
    .asJson
    .check(status.is(200));

  val getDataFromApi = http("DataPointsGet")
    .get(webBackEndBaseUrl + "DataPoints")
    .headers(webBackEndHeaders)
    .check(status.is(200))

  // Build Scenario
  val scn = scenario("AdeSimulation")
    .exec(navigateToHomePage)
    .feed(wordListFeeder)
    .exec(postDataToApi)
    .exec(getDataFromApi)

  // https://gatling.io/docs/current/general/simulation_setup/
  setUp(
    scn
      .inject(
        // atOnceUsers(5),
        // rampUsersPerSec(10).to(100).during(10.minutes)
        atOnceUsers(1)
      )
      .protocols(webFrontEndProtocol)
  ).assertions(
    // https://gatling.io/docs/3.2/general/assertions/
    global.responseTime.max.lt(100)
  )
}
