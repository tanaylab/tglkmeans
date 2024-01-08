## R CMD check results

0 errors | 0 warnings | 1 note

* Fixed documentation problems from previous submission.
* The requirement for GNU make is due to the use of RcppParallel (which requires GNU make).
* This is a unix only package since it is using the package tgstat which is not available on windows.



