include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()
include(GoogleTest)

set(CTEST test/csrc)
file(GLOB_RECURSE ALL_TESTS ${CTEST}/*.cpp)

set(WITH_MKL_BLAS 0)
if(USE_MKL_BLAS AND DEFINED BLAS_INCLUDE_DIR)
  message(WARNING "YAAAAAAAAAAAAAAAAAAAAAAAY!")
  find_file(MKL_INCLUDE_FOUND mkl.h ${BLAS_INCLUDE_DIR} NO_DEFAULT_PATH)
  find_path(MKL_INCLUDE_DIR mkl.h ${BLAS_INCLUDE_DIR} NO_CACHE)
  if(MKL_INCLUDE_FOUND)
    message(WARNING "We found MKL! YAAAAAAAAAAAAAAAAAAAAAAAY v2!")
    message(WARNING "We found MKL: ${MKL_INCLUDE_FOUND}")
    # set(MKL_INCLUDE_DIR /opt/hostedtoolcache/Python/3.8.16/x64/include)
    
    message(WARNING "Including MKL DIR: ${MKL_INCLUDE_DIR}")
    
    include_directories(${MKL_INCLUDE_DIR})
    target_include_directories(${PROJECT_NAME} PUBLIC ${MKL_INCLUDE_DIR} NO_CACHE)

    # Link the required MKL libraries
    
   # find_library(MKL_LIB mkl_intel_lp64)
   # find_library(MKL_CORE_LIB mkl_core)
   # find_library(MKL_THREAD_LIB mkl_gnu_thread)

   # target_link_libraries(${PROJECT_NAME} PRIVATE ${MKL_LIB} ${MKL_CORE_LIB} ${MKL_THREAD_LIB})
    set(WITH_MKL_BLAS 1)
  else()
    if(WITH_COV)
      message(FATAL_ERROR "The mkl.h file was not found - pass the correct directory or set USE_MKL_BLAS=OFF.")
    else()
      message(WARNING "The mkl.h file was not found - building pyg-lib without MKL BLAS support.")
    endif()
  endif()
endif()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pyg_lib/csrc/config.h.in "${CMAKE_CURRENT_SOURCE_DIR}/pyg_lib/csrc/config.h")

if(MKL_INCLUDE_FOUND)
    target_include_directories(${PROJECT_NAME} PUBLIC ${BLAS_INCLUDE_DIR})
    message(WARNING "Including directory: ${BLAS_INCLUDE_DIR}")
endif()

foreach(test ${ALL_TESTS})
    get_filename_component(name ${test} NAME_WE)
    add_executable(${name} ${test})
    target_link_libraries(${name} ${PROJECT_NAME} gtest_main torch)
    gtest_discover_tests(${name})
endforeach()
