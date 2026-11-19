cmake_minimum_required(VERSION 3.13)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/util/arm-gcc-toolchain.cmake")
project(USART_Communication_Rx_IT_CM33_NonSecure C ASM)

include(util/m33-firmware.cmake)

add_m33_firmware(
    "CM33/NonSecure/Src/main.c"
    "CM33/NonSecure/Src/stm32mp2xx_hal_msp.c"
    "CM33/NonSecure/Src/stm32mp2xx_it.c"
    "CM33/NonSecure/Src/syscalls.c"
    "CM33/NonSecure/Src/system_stm32mp2xx.c"
    "startup_stm32mp257cxx_m33.s"
    "${hal}/Src/stm32mp2xx_hal.c"
    "${hal}/Src/stm32mp2xx_hal_cortex.c"
    "${hal}/Src/stm32mp2xx_hal_dcache.c"
    "${hal}/Src/stm32mp2xx_hal_icache.c"
    "${hal}/Src/stm32mp2xx_hal_ipcc.c"
    "${hal}/Src/stm32mp2xx_hal_pwr.c"
    "${hal}/Src/stm32mp2xx_hal_pwr_ex.c"
    "${hal}/Src/stm32mp2xx_hal_rcc.c"
    "${hal}/Src/stm32mp2xx_hal_rcc_ex.c"
    "${hal}/Src/stm32mp2xx_ll_exti.c"
    "${hal}/Src/stm32mp2xx_ll_rcc.c"
    "${utilities}/CoproSync/copro_sync.c"
    "${utilities}/ResourcesManager/res_mgr.c"
)
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    "CM33/NonSecure/Inc"
)
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    ICACHE_DCACHE_USE USE_FULL_LL_DRIVER
)
