// Minimal Embedded Swift app for Waveshare ESP32-P4-ETH.
// Uses native Embedded Swift print() with putchar.c for serial output.

@c(app_main) public func app_main() {
  let delayTicks = (2 * 1000) / (1000 / UInt32(configTICK_RATE_HZ))

  while true {
    print("Hello from Embedded Swift on Waveshare ESP32-P4-ETH!")
    vTaskDelay(delayTicks)
  }
}
