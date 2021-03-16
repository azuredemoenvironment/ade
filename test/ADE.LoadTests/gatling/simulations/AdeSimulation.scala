// Idea borrowed from https://medium.com/@SamPFacer/a-different-way-of-writing-gatling-scenarios-5d45168b6199
package ade

import com.redis._
import com.redis.{RedisClient, RedisClientPool}
import io.gatling.core.feeder.{Feeder, FeederBuilder}
import io.gatling.core.Predef._
import io.gatling.core.structure._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import scala.concurrent.duration._
import scala.util.parsing.json.JSON

final case class RedisDataSetFeeder(
    clientPool: RedisClientPool,
    key: String
) extends FeederBuilder {

  override def apply(): Feeder[Any] = {
    def mapJson(data: String): Map[String, String] = {
      val sanitizedData = data.filter(_ >= ' ')
      println("Mapping Value to JSON")
      println(sanitizedData)
      val jsonMap: Map[String, Any] =
        JSON.parseFull(sanitizedData).get.asInstanceOf[Map[String, Any]]

      println("Mapping JSON to Map")
      val mappedValues: Map[String, String] = Map(
        "decimalValue" -> jsonMap.getOrElse("overall", 5.0).toString,
        "booleanValue" -> jsonMap.getOrElse("verified", false).toString,
        "stringValue"  -> jsonMap.getOrElse("reviewerName", "N/A").toString,
        "integerValue" -> scala.util.Random.nextInt(100).toString
      )

      mappedValues
    }

    def next: Option[Map[String, String]] = clientPool.withClient { client =>
      println("Getting Value from Redis")
      val value = client.lpop(key)
      println(value)

      println("Assigning Map to Return Value")
      val mappedValue = value.map(value => mapJson(value))

      println(mappedValue)
      println(mappedValue.isDefined)
      mappedValue
    }

    Iterator
      .continually(next)
      .takeWhile(_.isDefined)
      .map(_.get)
  }
}

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
  val wordListFeeder = RedisDataSetFeeder(redisPool, "DATA")

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
        """{ "booleanValue": ${booleanValue}, "decimalValue": ${decimalValue}, "integerValue": ${integerValue}, "stringValue": "${stringValue}"}"""
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
    .feed(wordListFeeder)
    .exec(navigateToHomePage)
    .exec(
      pause(
        1.second,
        10.seconds
      )
    )
    .exec(postDataToApi)
    .exec(
      pause(
        1.second,
        10.seconds
      )
    )
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
