// Bridging header for Embedded Swift <-> ESP-IDF.
// Provides app_main entry, FreeRTOS; putchar.c provides serial for print().

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"
