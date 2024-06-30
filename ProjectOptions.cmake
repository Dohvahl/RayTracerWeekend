# include(cmake/SystemLink.cmake)
# include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)
include(CMakePrintHelpers)

macro(RTWeekend_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(RTWeekend_setup_options)
  option(RTWeekend_ENABLE_HARDENING "Enable hardening" ON)
  option(RTWeekend_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    RTWeekend_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    RTWeekend_ENABLE_HARDENING
    OFF)

  RTWeekend_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR RTWeekend_PACKAGING_MAINTAINER_MODE)
    option(RTWeekend_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(RTWeekend_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(RTWeekend_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(RTWeekend_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(RTWeekend_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(RTWeekend_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(RTWeekend_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(RTWeekend_ENABLE_PCH "Enable precompiled headers" OFF)
    option(RTWeekend_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(RTWeekend_ENABLE_IPO "Enable IPO/LTO" ON)
    option(RTWeekend_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(RTWeekend_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(RTWeekend_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(RTWeekend_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(RTWeekend_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(RTWeekend_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(RTWeekend_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(RTWeekend_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(RTWeekend_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(RTWeekend_ENABLE_PCH "Enable precompiled headers" OFF)
    option(RTWeekend_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      RTWeekend_ENABLE_IPO
      RTWeekend_WARNINGS_AS_ERRORS
      RTWeekend_ENABLE_USER_LINKER
      RTWeekend_ENABLE_SANITIZER_ADDRESS
      RTWeekend_ENABLE_SANITIZER_LEAK
      RTWeekend_ENABLE_SANITIZER_UNDEFINED
      RTWeekend_ENABLE_SANITIZER_THREAD
      RTWeekend_ENABLE_SANITIZER_MEMORY
      RTWeekend_ENABLE_UNITY_BUILD
      RTWeekend_ENABLE_CLANG_TIDY
      RTWeekend_ENABLE_CPPCHECK
      RTWeekend_ENABLE_COVERAGE
      RTWeekend_ENABLE_PCH
      RTWeekend_ENABLE_CACHE)
  endif()

endmacro()

macro(RTWeekend_global_options)
  if(RTWeekend_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    RTWeekend_enable_ipo()
  endif()

  RTWeekend_supports_sanitizers()

  if(RTWeekend_ENABLE_HARDENING AND RTWeekend_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR RTWeekend_ENABLE_SANITIZER_UNDEFINED
       OR RTWeekend_ENABLE_SANITIZER_ADDRESS
       OR RTWeekend_ENABLE_SANITIZER_THREAD
       OR RTWeekend_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${RTWeekend_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${RTWeekend_ENABLE_SANITIZER_UNDEFINED}")
    RTWeekend_enable_hardening(RTWeekend_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(RTWeekend_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(RTWeekend_warnings INTERFACE)
  add_library(RTWeekend_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  RTWeekend_set_project_warnings(
    RTWeekend_warnings
    ${RTWeekend_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(RTWeekend_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    RTWeekend_configure_linker(RTWeekend_options)
  endif()

  include(cmake/Sanitizers.cmake)
  RTWeekend_enable_sanitizers(
    RTWeekend_options
    ${RTWeekend_ENABLE_SANITIZER_ADDRESS}
    ${RTWeekend_ENABLE_SANITIZER_LEAK}
    ${RTWeekend_ENABLE_SANITIZER_UNDEFINED}
    ${RTWeekend_ENABLE_SANITIZER_THREAD}
    ${RTWeekend_ENABLE_SANITIZER_MEMORY})

  set_target_properties(RTWeekend_options PROPERTIES UNITY_BUILD ${RTWeekend_ENABLE_UNITY_BUILD})

  if(RTWeekend_ENABLE_PCH)
    target_precompile_headers(
      RTWeekend_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(RTWeekend_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    RTWeekend_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(RTWeekend_ENABLE_CLANG_TIDY)
    RTWeekend_enable_clang_tidy(RTWeekend_options ${RTWeekend_WARNINGS_AS_ERRORS})
  endif()

  if(RTWeekend_ENABLE_CPPCHECK)
    RTWeekend_enable_cppcheck(${RTWeekend_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(RTWeekend_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    RTWeekend_enable_coverage(RTWeekend_options)
  endif()

  if(RTWeekend_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(RTWeekend_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(RTWeekend_ENABLE_HARDENING AND NOT RTWeekend_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR RTWeekend_ENABLE_SANITIZER_UNDEFINED
       OR RTWeekend_ENABLE_SANITIZER_ADDRESS
       OR RTWeekend_ENABLE_SANITIZER_THREAD
       OR RTWeekend_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    RTWeekend_enable_hardening(RTWeekend_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
