// Idea borrowed from https://medium.com/@SamPFacer/a-different-way-of-writing-gatling-scenarios-5d45168b6199
package ade

import scala.concurrent.duration._

import com.redis._
import io.gatling.core.Predef._
import io.gatling.core.structure._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.redis.Predef._
import scala.util.parsing.json.JSON

class AdeSimulation extends Simulation {
  // Environment Variables
  val webFrontEndDomain         = System.getProperty("webFrontEndDomain", "localhost:8080")
  val webBackEndDomain          = System.getProperty("webBackEndDomain", "localhost:8888")
  val redisHost                 = System.getProperty("redisHost", "localhost")
  val redisPort                 = Integer.getInteger("redisPort", 6379)
  val usersPerSecond: Double    = System.getProperty("usersPerSecond", "10").toDouble
  val maxUsersPerSecond: Double = System.getProperty("maxUsersPerSecond", "200").toDouble
  val overMinutes: Integer      = Integer.getInteger("overMinutes", 10)

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
  val webFrontEndBaseUrl  = "http://" + webFrontEndDomain + "/"
  val webFrontEndHeaders  = baseHeaders + ("Host" -> webFrontEndDomain)
  val webFrontEndProtocol = http.baseUrl(webFrontEndDomain)

  val webBackEndBaseUrl  = "http://" + webBackEndDomain + "/"
  val webBackEndHeaders  = baseHeaders + ("Host" -> webBackEndDomain)
  val webBackEndProtocol = http.baseUrl(webBackEndDomain)

  // Value Generation
  val redisPool      = new RedisClientPool(redisHost, redisPort)
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
        """{ "booleanValue": ${verified}, "decimalValue": ${overall}, "integerValue": 1, "stringValue": "${reviewerName}"}"""
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
    .exec({ session =>
      // Pull the "DATA" attribute that came from redis and convert it to JSON
      val data              = session("DATA").as[String]
      val json: Option[Any] = JSON.parseFull(data)

      // Next convert that JSON into a Map
      val map: Map[String, Any] = json.get.asInstanceOf[Map[String, Any]]

      // Remove the original DATA attribute and assign the map values to the session
      session.remove("DATA").setAll(map)
    })
    .exec(postDataToApi)
    .exec(getDataFromApi)

  // https://gatling.io/docs/current/general/simulation_setup/
  setUp(
    scn
      .inject(
        rampUsersPerSec(usersPerSecond).to(maxUsersPerSecond).during(overMinutes.minutes)
      )
      .protocols(webFrontEndProtocol)
  ).assertions(
    // https://gatling.io/docs/3.2/general/assertions/
    global.responseTime.max.lt(100)
  )
}
