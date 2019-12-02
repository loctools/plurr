# Objective-C implementation

This is the Objective-C implementation of Plurr.

## Installation

Plurr is a simple library with no dependencies so we just distribute the .m and .h files.
To install, drag and drop Plurr.m and Plurr.h into your Xcode project and select the targets where it should be added.

## Usage

To use, pass the translated plurr-formatted string to `stringWithFormat:vars:`.

```obj-c
NSString * localizedPlurrFormat = NSLocalizedString(
  @"{MINUTE_PLURAL:{MINUTE} minute|{MINUTE} minutes} and {SECOND_PLURAL:{SECOND} second|{SECOND} seconds} remaining",
  @"Plurr string describing how many minutes and seconds remain");
NSDictionary *arguments = @{@"MINUTE": @(minutes), @"SECOND": @(seconds)};

NSString *localizedString = [[Plurr defaultPlurr] stringWithFormat:localizedPlurrFormat, arguments:arguments];
```

Alternatively, use the `PlurrLocalizedString()` macro which calls NSLocalizedString internally:

```obj-c
NSString * localizedPlurrFormat = NSLocalizedString(
  @"{MINUTE_PLURAL:{MINUTE} minute|{MINUTE} minutes} and {SECOND_PLURAL:{SECOND} second|{SECOND} seconds} remaining",
  @"Plurr string describing how many minutes and seconds remain");
NSDictionary *arguments = @{@"MINUTE": @(minutes), @"SECOND": @(seconds)};

NSString *localizedString = PlurrLocalizedString(localizedPlurrFormat, arguments);
```

Ensure that your Plurr format strings are in Localizable.strings and that they have been translated accordingly in their language-specific variants.
