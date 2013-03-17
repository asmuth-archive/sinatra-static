# Changelog

## 1.0.1 - 2013-03-17

* Add missing rake & rack-test depencendies

## 1.0.0 - 2013-03-17

* You must now register Sinatra::Export extension.
* Sinatra::AdvancedRoutes is now auto loaded. (#5)
* Renamed build! method export!.

## 0.9.5

* Improvement : signed gem.

## 0.9.4

* Now set files mtime according to response Last-Modified header

## 0.9.3

* Removed unnecessary development dependencies.

## 0.9.2

* Bug fix: Correctly support path with file extension (.json, .csv, etc.). Issue #1

## 0.9.1

* API CHANGE: Now calling .build! without path parameter, using Sinatra application :public_folder setting.
* Feature: Added a rake task sinatra:export