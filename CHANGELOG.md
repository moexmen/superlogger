# Change Log

## [0.1.0] - 2016-05-03
### Added
- Added request_id to logs belonging to the same page request.

### Changed
- Rewrote Superlogger to remove monkey patching. Now logging is done through `Rails.logger`
- Superlogger will now only unsubscribe log subscribers that it supports.

[0.1.0]: https://github.com/moexmen/superlogger/compare/v0.0.2...v0.1.0
