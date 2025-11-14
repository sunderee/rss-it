//
// Manually maintained protobuf definitions for rss_it_library.
// Generated via protoc is preferred; until tooling is wired into CI this file
// is kept in source control to unblock local development.
//

// ignore_for_file: annotate_overrides, camel_case_types, constant_identifier_names
// ignore_for_file: library_prefixes, non_constant_identifier_names
// ignore_for_file: prefer_final_fields, unused_import, unnecessary_this

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ErrorKind extends $pb.ProtobufEnum {
  static const ErrorKind ERROR_KIND_UNKNOWN = ErrorKind._(0, 'ERROR_KIND_UNKNOWN');
  static const ErrorKind ERROR_KIND_SERIALIZATION = ErrorKind._(1, 'ERROR_KIND_SERIALIZATION');
  static const ErrorKind ERROR_KIND_NETWORK = ErrorKind._(2, 'ERROR_KIND_NETWORK');
  static const ErrorKind ERROR_KIND_PARSING = ErrorKind._(3, 'ERROR_KIND_PARSING');
  static const ErrorKind ERROR_KIND_VALIDATION = ErrorKind._(4, 'ERROR_KIND_VALIDATION');
  static const ErrorKind ERROR_KIND_INTERNAL = ErrorKind._(5, 'ERROR_KIND_INTERNAL');

  static const $core.List<ErrorKind> values = <ErrorKind>[
    ERROR_KIND_UNKNOWN,
    ERROR_KIND_SERIALIZATION,
    ERROR_KIND_NETWORK,
    ERROR_KIND_PARSING,
    ERROR_KIND_VALIDATION,
    ERROR_KIND_INTERNAL,
  ];

  static final $core.Map<$core.int, ErrorKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ErrorKind? valueOf($core.int value) => _byValue[value];

  const ErrorKind._($core.int v, $core.String n) : super(v, n);
}

class ParseFeedsStatus extends $pb.ProtobufEnum {
  static const ParseFeedsStatus SUCCESS = ParseFeedsStatus._(0, 'SUCCESS');
  static const ParseFeedsStatus ERROR = ParseFeedsStatus._(1, 'ERROR');
  static const ParseFeedsStatus PARTIAL = ParseFeedsStatus._(2, 'PARTIAL');

  static const $core.List<ParseFeedsStatus> values = <ParseFeedsStatus>[
    SUCCESS,
    ERROR,
    PARTIAL,
  ];

  static final $core.Map<$core.int, ParseFeedsStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ParseFeedsStatus? valueOf($core.int value) => _byValue[value];

  const ParseFeedsStatus._($core.int v, $core.String n) : super(v, n);
}

class ValidateFeedRequest extends $pb.GeneratedMessage {
  factory ValidateFeedRequest({
    $core.String? url,
  }) {
    final $result = create();
    if (url != null) {
      $result.url = url;
    }
    return $result;
  }
  ValidateFeedRequest._() : super();
  factory ValidateFeedRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ValidateFeedRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ValidateFeedRequest',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  ValidateFeedRequest clone() => ValidateFeedRequest()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  ValidateFeedRequest copyWith(void Function(ValidateFeedRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateFeedRequest)) as ValidateFeedRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateFeedRequest create() => ValidateFeedRequest._();
  ValidateFeedRequest createEmptyInstance() => create();
  static $pb.PbList<ValidateFeedRequest> createRepeated() => $pb.PbList<ValidateFeedRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidateFeedRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateFeedRequest>(create);
  static ValidateFeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => clearField(1);
}

class ErrorDetail extends $pb.GeneratedMessage {
  factory ErrorDetail({
    ErrorKind? kind,
    $core.String? message,
    $core.String? url,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (message != null) {
      $result.message = message;
    }
    if (url != null) {
      $result.url = url;
    }
    return $result;
  }
  ErrorDetail._() : super();
  factory ErrorDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ErrorDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ErrorDetail',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..e<ErrorKind>(
      1,
      'kind',
      $pb.PbFieldType.OE,
      defaultOrMaker: ErrorKind.ERROR_KIND_UNKNOWN,
      valueOf: ErrorKind.valueOf,
      enumValues: ErrorKind.values,
    )
    ..aOS(2, 'message')
    ..aOS(3, 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  ErrorDetail clone() => ErrorDetail()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  ErrorDetail copyWith(void Function(ErrorDetail) updates) =>
      super.copyWith((message) => updates(message as ErrorDetail)) as ErrorDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ErrorDetail create() => ErrorDetail._();
  ErrorDetail createEmptyInstance() => create();
  static $pb.PbList<ErrorDetail> createRepeated() => $pb.PbList<ErrorDetail>();
  @$core.pragma('dart2js:noInline')
  static ErrorDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ErrorDetail>(create);
  static ErrorDetail? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(ErrorKind v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => clearField(3);
}

class ValidateFeedResponse extends $pb.GeneratedMessage {
  factory ValidateFeedResponse({
    $core.bool? valid,
    ErrorDetail? error,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ValidateFeedResponse._() : super();
  factory ValidateFeedResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ValidateFeedResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ValidateFeedResponse',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..aOB(1, 'valid')
    ..aOM<ErrorDetail>(2, 'error', subBuilder: ErrorDetail.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  ValidateFeedResponse clone() => ValidateFeedResponse()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  ValidateFeedResponse copyWith(void Function(ValidateFeedResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateFeedResponse)) as ValidateFeedResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateFeedResponse create() => ValidateFeedResponse._();
  ValidateFeedResponse createEmptyInstance() => create();
  static $pb.PbList<ValidateFeedResponse> createRepeated() => $pb.PbList<ValidateFeedResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidateFeedResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateFeedResponse>(create);
  static ValidateFeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);

  @$pb.TagNumber(2)
  ErrorDetail get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(ErrorDetail v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
  @$pb.TagNumber(2)
  ErrorDetail ensureError() => $_ensure(1);
}

class ParseFeedsRequest extends $pb.GeneratedMessage {
  factory ParseFeedsRequest({
    $core.Iterable<$core.String>? urls,
  }) {
    final $result = create();
    if (urls != null) {
      $result.urls.addAll(urls);
    }
    return $result;
  }
  ParseFeedsRequest._() : super();
  factory ParseFeedsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ParseFeedsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ParseFeedsRequest',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..pPS(1, 'urls')
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  ParseFeedsRequest clone() => ParseFeedsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  ParseFeedsRequest copyWith(void Function(ParseFeedsRequest) updates) =>
      super.copyWith((message) => updates(message as ParseFeedsRequest)) as ParseFeedsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParseFeedsRequest create() => ParseFeedsRequest._();
  ParseFeedsRequest createEmptyInstance() => create();
  static $pb.PbList<ParseFeedsRequest> createRepeated() => $pb.PbList<ParseFeedsRequest>();
  @$core.pragma('dart2js:noInline')
  static ParseFeedsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParseFeedsRequest>(create);
  static ParseFeedsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get urls => $_getList(0);
}

class FeedItem extends $pb.GeneratedMessage {
  factory FeedItem({
    $core.String? title,
    $core.String? description,
    $core.String? link,
    $core.String? image,
    $core.String? published,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (link != null) {
      $result.link = link;
    }
    if (image != null) {
      $result.image = image;
    }
    if (published != null) {
      $result.published = published;
    }
    return $result;
  }
  FeedItem._() : super();
  factory FeedItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FeedItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FeedItem',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'title')
    ..aOS(2, 'description')
    ..aOS(3, 'link')
    ..aOS(4, 'image')
    ..aOS(5, 'published')
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  FeedItem clone() => FeedItem()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  FeedItem copyWith(void Function(FeedItem) updates) =>
      super.copyWith((message) => updates(message as FeedItem)) as FeedItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedItem create() => FeedItem._();
  FeedItem createEmptyInstance() => create();
  static $pb.PbList<FeedItem> createRepeated() => $pb.PbList<FeedItem>();
  @$core.pragma('dart2js:noInline')
  static FeedItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedItem>(create);
  static FeedItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get link => $_getSZ(2);
  @$pb.TagNumber(3)
  set link($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLink() => $_has(2);
  @$pb.TagNumber(3)
  void clearLink() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get image => $_getSZ(3);
  @$pb.TagNumber(4)
  set image($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasImage() => $_has(3);
  @$pb.TagNumber(4)
  void clearImage() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get published => $_getSZ(4);
  @$pb.TagNumber(5)
  set published($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasPublished() => $_has(4);
  @$pb.TagNumber(5)
  void clearPublished() => clearField(5);
}

class Feed extends $pb.GeneratedMessage {
  factory Feed({
    $core.String? url,
    $core.String? title,
    $core.String? description,
    $core.String? image,
    $core.Iterable<FeedItem>? items,
  }) {
    final $result = create();
    if (url != null) {
      $result.url = url;
    }
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (image != null) {
      $result.image = image;
    }
    if (items != null) {
      $result.items.addAll(items);
    }
    return $result;
  }
  Feed._() : super();
  factory Feed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Feed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Feed',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'url')
    ..aOS(2, 'title')
    ..aOS(3, 'description')
    ..aOS(5, 'image')
    ..pc<FeedItem>(6, 'items', $pb.PbFieldType.PM, subBuilder: FeedItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  Feed clone() => Feed()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  Feed copyWith(void Function(Feed) updates) => super.copyWith((message) => updates(message as Feed)) as Feed;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Feed create() => Feed._();
  Feed createEmptyInstance() => create();
  static $pb.PbList<Feed> createRepeated() => $pb.PbList<Feed>();
  @$core.pragma('dart2js:noInline')
  static Feed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Feed>(create);
  static Feed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(5)
  $core.String get image => $_getSZ(3);
  @$pb.TagNumber(5)
  set image($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasImage() => $_has(3);
  @$pb.TagNumber(5)
  void clearImage() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<FeedItem> get items => $_getList(4);
}

class ParseFeedsResponse extends $pb.GeneratedMessage {
  factory ParseFeedsResponse({
    ParseFeedsStatus? status,
    $core.Iterable<Feed>? feeds,
    $core.Iterable<ErrorDetail>? errors,
    ErrorDetail? fatalError,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (feeds != null) {
      $result.feeds.addAll(feeds);
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    if (fatalError != null) {
      $result.fatalError = fatalError;
    }
    return $result;
  }
  ParseFeedsResponse._() : super();
  factory ParseFeedsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ParseFeedsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ParseFeedsResponse',
    package: const $pb.PackageName('proto'),
    createEmptyInstance: create,
  )
    ..e<ParseFeedsStatus>(
      1,
      'status',
      $pb.PbFieldType.OE,
      defaultOrMaker: ParseFeedsStatus.SUCCESS,
      valueOf: ParseFeedsStatus.valueOf,
      enumValues: ParseFeedsStatus.values,
    )
    ..pc<Feed>(2, 'feeds', $pb.PbFieldType.PM, subBuilder: Feed.create)
    ..pc<ErrorDetail>(3, 'errors', $pb.PbFieldType.PM, subBuilder: ErrorDetail.create)
    ..aOM<ErrorDetail>(4, 'fatalError', subBuilder: ErrorDetail.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Use deepCopy instead. Will be removed in next major version')
  ParseFeedsResponse clone() => ParseFeedsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Use rebuild instead. Will be removed in next major version')
  ParseFeedsResponse copyWith(void Function(ParseFeedsResponse) updates) =>
      super.copyWith((message) => updates(message as ParseFeedsResponse)) as ParseFeedsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParseFeedsResponse create() => ParseFeedsResponse._();
  ParseFeedsResponse createEmptyInstance() => create();
  static $pb.PbList<ParseFeedsResponse> createRepeated() => $pb.PbList<ParseFeedsResponse>();
  @$core.pragma('dart2js:noInline')
  static ParseFeedsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParseFeedsResponse>(create);
  static ParseFeedsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ParseFeedsStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ParseFeedsStatus v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Feed> get feeds => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<ErrorDetail> get errors => $_getList(2);

  @$pb.TagNumber(4)
  ErrorDetail get fatalError => $_getN(3);
  @$pb.TagNumber(4)
  set fatalError(ErrorDetail v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFatalError() => $_has(3);
  @$pb.TagNumber(4)
  void clearFatalError() => clearField(4);
  @$pb.TagNumber(4)
  ErrorDetail ensureFatalError() => $_ensure(3);
}
