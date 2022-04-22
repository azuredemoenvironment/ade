package ade

import com.redis._
import io.gatling.core.feeder.{Feeder, FeederBuilder}
import scala.util.parsing.json.JSON

final case class AdeDataFeeder(
    redisHost: String,
    redisPort: Int,
    key: String
) extends FeederBuilder {
  val clientPool: RedisClientPool = new RedisClientPool(redisHost, redisPort);

  override def apply(): Feeder[Any] = {
    def mapJson(data: String): Map[String, String] = {
      // Filter out control characters from the data (reduces errors)
      val sanitizedData = data.filter(_ >= ' ')

      // Map data to JSON
      println(s"Mapping Value to JSON: $sanitizedData")
      val json = JSON.parseFull(sanitizedData)

      json match {
        case Some(jsonMap: Map[String, Any]) => {
          Map(
            "decimalValue" -> jsonMap.getOrElse("overall", 5.0).toString,
            "booleanValue" -> jsonMap.getOrElse("verified", false).toString,
            "stringValue"  -> jsonMap.getOrElse("reviewerName", "N/A").toString,
            "integerValue" -> scala.util.Random.nextInt(100).toString
          )
        }
        case None => {
          println(s"Data was corrupted, generating a filler value. Data was: $data.")
          Map(
            "decimalValue" -> scala.util.Random.nextInt(100).toString,
            "booleanValue" -> "false",
            "stringValue"  -> "Corrupted Data",
            "integerValue" -> scala.util.Random.nextInt(100).toString
          )
        }
      }
    }

    def next: Option[Map[String, String]] = clientPool.withClient { client =>
      // Get the next entry off the list in Redis
      val value = client.lpop(key)

      // Map the value of that entry to a JSON-based Map
      value.map(value => mapJson(value))
    }

    Iterator
      .continually(next)
      .takeWhile(_.isDefined)
      .map(_.get)
  }
}
