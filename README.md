
# dio_retry_interceptor

A custom [Dio](https://pub.dev/packages/dio) interceptor for Flutter/Dart that automatically retries HTTP requests when network connectivity is restored. Ideal for handling flaky or slow network conditions.

---

## ✨ Features

- ✅ Retries failed requests on connection error or timeout
- 🔁 Supports configurable retry attempts
- 🔌 Checks connectivity before retrying
- 🛠️ Toggle retry for POST/PUT requests
- 🐞 Optional debug logs for retry attempts

---


## 🚀 Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dio_retry_interceptor: ^<latest_version>
```  

Then run:

`flutter pub get`  

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:dio_retry_interceptor/dio_retry_interceptor.dart';

...

final dio = Dio();

dio.interceptors.add(
  RetryOnConnectionChangeInterceptor(
    dio,
    maxRetryAttempts: 3,
    retryPost: false,
    enableLogging: true,
  ),
);

Optionally Mark a Request as Retryable (for non-GET)
await dio.post(
  '/your-api',
  data: {...},
  options: Options(
    extra: {'retryable': true},
  ),
);


```
| Option             | Description                              | Default |
| ------------------ | ---------------------------------------- | ------- |
| `maxRetryAttempts` | Max number of retry attempts per request | `3`     |
| `retryPost`        | Allow retry for POST/PUT requests        | `false` |
| `enableLogging`    | Show console logs for each retry attempt | `false` |


## Contributors
Feel free to open issues or submit PRs to improve this package.



