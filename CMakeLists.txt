cmake_minimum_required(VERSION 3.7)
project(tglkmeans)

set(CMAKE_CXX_STANDARD 11)

include_directories(net/mraid14/export/data/users/eladch/tools/CO7/R/3.3.2/lib64/R/include/ /home/aviezerl/R/x86_64-pc-linux-gnu-library/3.3/Rcpp/include/)

set(SOURCE_FILES src/TGLkmeans.cpp main.cpp src/KMeans.cpp src/KMeans.h src/KMeansCenterBase.cpp src/KMeansCenterBase.h src/Random.cpp src/Random.h src/KMeansCenterMean.cpp src/KMeansCenterMean.h src/KMeansCenterMeanEuclid.cpp src/KMeansCenterMeanEuclid.h src/KMeansCenterMeanPearson.cpp src/KMeansCenterMeanPearson.h src/IndirectSort.h src/AParamStat.h src/AParamStat.cpp  src/Ranking.h src/Ranking.cpp src/KMeansCenterMeanSpearman.cpp src/KMeansCenterMeanSpearman.h other/options.h other/options.cpp other/strutil.h other/strutil.cpp other/BufferedFile.h other/BufferedFile.cpp other/TGLException.h other/error.h /home/aviezerl/R/x86_64-pc-linux-gnu-library/3.3/Rcpp/include/Rcpp.h)
#set(SOURCE_FILES src/KMeans.cpp src/KMeans.h src/KMeansCenterBase.cpp src/KMeansCenterBase.h src/Random.cpp src/Random.h src/KMeansCenterMean.cpp src/KMeansCenterMean.h src/KMeansCenterMeanEuclid.cpp src/KMeansCenterMeanEuclid.h src/KMeansCenterMeanPearson.cpp src/KMeansCenterMeanPearson.h src/IndirectSort.h src/AParamStat.h src/AParamStat.cpp  src/Ranking.h src/Ranking.cpp src/KMeansCenterMeanSpearman.cpp src/KMeansCenterMeanSpearman.h)

add_executable(tglkmeans ${SOURCE_FILES})
#add_library(tglkmeans ${SOURCE_FILES})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

find_package(R REQUIRED)
message("R libraries: ${R_LIBRARIES}")
message("R include dirs: ${R_INCLUDE_DIR} ${Rcpp_INCLUDE_DIR}")

#add_library(tglk SHARED src/foo.cpp)
include_directories(tglkmeans ${R_INCLUDE_DIR} ${Rcpp_INCLUDE_DIR})
target_link_libraries(tglkmeans ${R_LIBRARIES})

#install(TARGETS tglkmeans DESTINATION lib)

##if(${LIBR_FOUND})
##else()
##    message(FATAL_ERROR "No R...")
##endif()
#message(STATUS ${CMAKE_SOURCE_DIR})
#execute_process(
#        COMMAND ${LIBR_EXECUTABLE} "--slave" "-e" "stopifnot(require('Rcpp'));cat(Rcpp:::Rcpp.system.file('include'))"
#        OUTPUT_VARIABLE LIBRCPP_INCLUDE_DIRS
#)
#include_directories(BEFORE ${LIBR_INCLUDE_DIRS})
#message(STATUS ${LIBR_INCLUDE_DIRS})
#include_directories(BEFORE ${LIBRCPP_INCLUDE_DIRS})
#message(STATUS ${LIBRCPP_INCLUDE_DIRS})
#add_custom_target(RcppPackage ALL
#        COMMAND find ${CMAKE_SOURCE_DIR} -name "*.o" -exec rm "{}" "\;"
#        COMMAND find ${CMAKE_SOURCE_DIR} -name "*.so" -exec rm "{}" "\;"
#        COMMAND ${LIBR_EXECUTABLE} "--slave" "-e" "\"stopifnot(require(devtools));document('${CMAKE_SOURCE_DIR}'); build('${CMAKE_SOURCE_DIR}'); install('${CMAKE_SOURCE_DIR}')\""
#        COMMAND ${LIBR_EXECUTABLE} CMD INSTALL "${CMAKE_SOURCE_DIR}")
#
#

