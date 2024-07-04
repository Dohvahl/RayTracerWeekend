add_executable(RTWeekend main.cpp)

target_link_libraries(
  RTWeekend
  PRIVATE 
		RTWeekend::iow
  		RTWeekend::RTWeekend_options
        RTWeekend::RTWeekend_warnings)

target_link_system_libraries(
  RTWeekend
  PRIVATE
          CLI11::CLI11
          fmt::fmt
        #   spdlog::spdlog
			# benchmark::benchmark
          lefticus::tools)

# target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")