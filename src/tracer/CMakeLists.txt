# Note that headers are optional, and do not affect add_library, but they will not
# show up in IDEs unless they are listed in add_library.

# Only for CMake 3.12 or later:
file(GLOB HEADER_LIST CONFIGURE_DEPENDS "${RTWeekend_SOURCE_DIR}/include/RTWeekend/*.hpp")
# set(HEADER_LIST "${ModernCMakeExample_SOURCE_DIR}/include/modern/lib.hpp")

# Make an automatic library - will be static or dynamic based on user setting
add_library(RTyWeekend
	color.cpp
	hittable_list.cpp
	hittable.cpp
	interval.cpp
	ray.cpp
	sphere.cpp
	vec3.cpp
	${HEADER_LIST})

add_library(RTWeekend::iow ALIAS RTyWeekend)

# We need this directory, and users of our library will need it too
target_include_directories(RTyWeekend PUBLIC 
	$<BUILD_INTERFACE:${RTWeekend_SOURCE_DIR}/include>
	$<INSTALL_INTERFACE:include>	
)

target_link_libraries(
	RTyWeekend
	PRIVATE
		RTWeekend::RTWeekend_options
		RTWeekend::RTWeekend_warnings
)

# IDEs should put the headers in a nice place
source_group(
  TREE "${PROJECT_SOURCE_DIR}/include"
  PREFIX "Header Files"
  FILES ${HEADER_LIST})
