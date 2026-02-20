#include "esp_rom_sys.h"

int putchar(int c) {
    esp_rom_printf("%c", c);
    return c;
}
