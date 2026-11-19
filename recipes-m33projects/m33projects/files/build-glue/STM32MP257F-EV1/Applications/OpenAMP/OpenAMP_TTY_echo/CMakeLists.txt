cmake_minimum_required(VERSION 3.13)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/util/arm-gcc-toolchain.cmake")
project(OpenAMP_TTY_echo_CM33_NonSecure C ASM)

include(util/m33-firmware.cmake)

# Generate the libmetal headers using ST's generic ARM configuration.
execute_process(
    COMMAND "${CMAKE_COMMAND}" -S "${openamp}/libmetal"
        -B "${CMAKE_CURRENT_BINARY_DIR}/libmetal"
        -DCMAKE_TOOLCHAIN_FILE=cmake/platforms/stm32mp-generic-gcc.cmake
        -DWITH_DOC=OFF
    RESULT_VARIABLE libmetal_configure
)
if(NOT libmetal_configure EQUAL 0)
    message(FATAL_ERROR "Could not configure libmetal")
endif()

add_m33_firmware(
    "CM33/NonSecure/Core/Src/main.c"
    "CM33/NonSecure/Core/Src/stm32mp2xx_hal_msp.c"
    "CM33/NonSecure/Core/Src/stm32mp2xx_it.c"
    "CM33/NonSecure/OPENAMP/mbox_ipcc.c"
    "CM33/NonSecure/OPENAMP/openamp.c"
    "CM33/NonSecure/OPENAMP/openamp_log.c"
    "CM33/NonSecure/OPENAMP/rsc_table.c"
    "startup_stm32mp257cxx_m33.s"
    "${bsp}/stm32mp257f_eval.c"
    "${cmsis}/Source/Templates/system_stm32mp2xx_m33_ns.c"
    "${hal}/Src/stm32mp2xx_hal.c"
    "${hal}/Src/stm32mp2xx_hal_cortex.c"
    "${hal}/Src/stm32mp2xx_hal_dcache.c"
    "${hal}/Src/stm32mp2xx_hal_dma.c"
    "${hal}/Src/stm32mp2xx_hal_dma_ex.c"
    "${hal}/Src/stm32mp2xx_hal_exti.c"
    "${hal}/Src/stm32mp2xx_hal_gpio.c"
    "${hal}/Src/stm32mp2xx_hal_icache.c"
    "${hal}/Src/stm32mp2xx_hal_ipcc.c"
    "${hal}/Src/stm32mp2xx_hal_pwr.c"
    "${hal}/Src/stm32mp2xx_hal_pwr_ex.c"
    "${hal}/Src/stm32mp2xx_hal_rcc.c"
    "${hal}/Src/stm32mp2xx_hal_rcc_ex.c"
    "${hal}/Src/stm32mp2xx_hal_uart.c"
    "${hal}/Src/stm32mp2xx_hal_uart_ex.c"
    "${openamp}/libmetal/lib/device.c"
    "${openamp}/libmetal/lib/init.c"
    "${openamp}/libmetal/lib/io.c"
    "${openamp}/libmetal/lib/log.c"
    "${openamp}/libmetal/lib/shmem.c"
    "${openamp}/libmetal/lib/system/generic/condition.c"
    "${openamp}/libmetal/lib/system/generic/generic_device.c"
    "${openamp}/libmetal/lib/system/generic/generic_init.c"
    "${openamp}/libmetal/lib/system/generic/generic_io.c"
    "${openamp}/libmetal/lib/system/generic/generic_shmem.c"
    "${openamp}/libmetal/lib/system/generic/template/sys.c"
    "${openamp}/libmetal/lib/system/generic/time.c"
    "${openamp}/open-amp/lib/remoteproc/remoteproc_virtio.c"
    "${openamp}/open-amp/lib/rpmsg/rpmsg.c"
    "${openamp}/open-amp/lib/rpmsg/rpmsg_virtio.c"
    "${openamp}/open-amp/lib/virtio/virtio.c"
    "${openamp}/open-amp/lib/virtio/virtqueue.c"
    "${openamp}/virtual_driver/virt_uart.c"
    "${utilities}/CoproSync/copro_sync.c"
    "${utilities}/ResourcesManager/res_mgr.c"
    "${utilities}/Services/GenericServices/syscalls.c"
)
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    "CM33/NonSecure/Core/Inc"
    "CM33/NonSecure/OPENAMP"
    "${openamp}/open-amp/lib/include"
    "${openamp}/virtual_driver"
    "${CMAKE_CURRENT_BINARY_DIR}/libmetal/lib/include"
)
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    ICACHE_DCACHE_USE USE_HAL_DRIVER LINUX_RPROC_MASTER METAL_INTERNAL METAL_MAX_DEVICE_REGIONS=2 NO_ATOMIC_64_SUPPORT VIRTIO_DEVICE_ONLY
)
