# Buffer

[![Build Status](https://travis-ci.org/dbart01/Buffer.svg?branch=master)](https://travis-ci.org/dbart01/Buffer)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/dbart01/buffer.svg)](https://github.com/dbart01/Buffer/releases/latest)
[![GitHub license](https://img.shields.io/badge/license-MIT-orange.svg)](https://github.com/dbart01/Buffer/blob/master/LICENSE)

Buffer makes it easy to read from and write into a raw binary buffer without the discomfort of `UnsafeMutablePointer` and `UnsafeRawPointer`.

## Typed Access

A `Buffer` let's access it's underlying representation using "typed" reads and writes. Using this approach, the size of the value to written or read from buffer is dictated by `MemoryLayout<T>.stride` and is automatically inferred. For example, let's take a look at an empty, 64-byte buffer:

```swift
let buffer = Buffer(size: 64)
```

```
------- Buffer --------
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
```

Let's assume we want to use a 64-bit integer as a bit mask header. Each bytes is separated with an underscore to make it easier to identify.

```swift
let header = 0x01_00_11_00_10_11_01_10 as UInt64
```

We can write it directly into the buffer.

```swift
buffer.write(value: header)
```

```
------- Buffer --------
10 01 11 10 00 11 00 01
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
```

_NOTE_: The reversed byte order. This behaviour will differ depending on the endianness of your machine.

Reading the value out of the buffer is a similar process but has two alternatives. Since `Buffer` still needs to know the type of the value we're reading to infer the size, we have to provide it in one of two ways - explicitly or implicitly.

Using the implicit strategy, you can read from the buffer and assign directly to an instance variable. The type will be inferred without you having to declare it.

```swift
// Somewhere in your class
// private var header: UInt64

self.header = buffer.read()
```

Alternatively, you can provide the type explicitly. This is often preferred if writing into local variable with a declared type.

```swfit
let header = buffer.read(UInt64.self)
```