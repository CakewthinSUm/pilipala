import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/common/search_type.dart';
import 'package:pilipala/models/video/play/quality.dart';
import 'package:pilipala/models/video/play/url.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/pages/video/detail/replyReply/index.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:screen_brightness/screen_brightness.dart';

class VideoDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 路由传参
  String bvid = Get.parameters['bvid']!;
  RxInt cid = int.parse(Get.parameters['cid']!).obs;
  RxInt danmakuCid = 0.obs;
  String heroTag = Get.arguments['heroTag'];
  // 视频详情
  Map videoItem = {};
  // 视频类型 默认投稿视频
  SearchType videoType = Get.arguments['videoType'] ?? SearchType.video;

  /// tabs相关配置
  int tabInitialIndex = 0;
  late TabController tabCtr;
  RxList<String> tabs = <String>['简介', '评论'].obs;

  // 请求返回的视频信息
  late PlayUrlModel data;
  // 请求状态
  RxBool isLoading = false.obs;

  /// 播放器配置 画质 音质 解码格式
  late VideoQuality currentVideoQa;
  AudioQuality? currentAudioQa;
  late VideoDecodeFormats currentDecodeFormats;
  // 是否开始自动播放 存在多p的情况下，第二p需要为true
  RxBool autoPlay = true.obs;
  // 视频资源是否有效
  RxBool isEffective = true.obs;
  // 封面图的展示
  RxBool isShowCover = true.obs;
  // 硬解
  RxBool enableHA = true.obs;

  /// 本地存储
  Box userInfoCache = GStrorage.userInfo;
  Box localCache = GStrorage.localCache;
  Box setting = GStrorage.setting;

  int oid = 0;
  // 评论id 请求楼中楼评论使用
  int fRpid = 0;

  ReplyItemModel? firstFloor;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxString bgCover = ''.obs;
  PlPlayerController plPlayerController = PlPlayerController.getInstance();

  late VideoItem firstVideo;
  late AudioItem firstAudio;
  late String videoUrl;
  late String audioUrl;
  late Duration defaultST;
  // 亮度
  double? brightness;
  // 默认记录历史记录
  bool enableHeart = true;
  var userInfo;
  late bool isFirstTime = true;

  @override
  void onInit() {
    super.onInit();
    Map argMap = Get.arguments;
    userInfo = userInfoCache.get('userInfoCache');
    var keys = argMap.keys.toList();
    if (keys.isNotEmpty) {
      if (keys.contains('videoItem')) {
        var args = argMap['videoItem'];
        if (args.pic != null && args.pic != '') {
          videoItem['pic'] = args.pic;
        }
      }
      if (keys.contains('pic')) {
        videoItem['pic'] = argMap['pic'];
      }
    }
    tabCtr = TabController(length: 2, vsync: this);
    autoPlay.value =
        setting.get(SettingBoxKey.autoPlayEnable, defaultValue: true);
    enableHA.value = setting.get(SettingBoxKey.enableHA, defaultValue: true);

    if (userInfo == null ||
        localCache.get(LocalCacheKey.historyPause) == true) {
      enableHeart = false;
    }
    danmakuCid.value = cid.value;
  }

  showReplyReplyPanel() {
    PersistentBottomSheetController<void>? ctr =
        scaffoldKey.currentState?.showBottomSheet<void>((BuildContext context) {
      return VideoReplyReplyPanel(
        oid: oid,
        rpid: fRpid,
        closePanel: () => {
          fRpid = 0,
        },
        firstFloor: firstFloor,
        replyType: ReplyType.video,
        source: 'videoDetail',
      );
    });
    ctr?.closed.then((value) {
      fRpid = 0;
    });
  }

  /// 更新画质、音质
  /// TODO 继续进度播放
  updatePlayer() {
    defaultST = plPlayerController.position.value;
    plPlayerController.removeListeners();
    plPlayerController.isBuffering.value = false;
    plPlayerController.buffered.value = Duration.zero;

    /// 根据currentVideoQa和currentDecodeFormats 重新设置videoUrl
    List<VideoItem> videoList =
        data.dash!.video!.where((i) => i.id == currentVideoQa.code).toList();
    try {
      firstVideo = videoList
          .firstWhere((i) => i.codecs!.startsWith(currentDecodeFormats.code));
    } catch (_) {
      if (currentVideoQa == VideoQuality.dolbyVision) {
        firstVideo = videoList.first;
        currentDecodeFormats =
            VideoDecodeFormatsCode.fromString(videoList.first.codecs!)!;
      } else {
        // 当前格式不可用
        currentDecodeFormats = VideoDecodeFormatsCode.fromString(setting.get(
            SettingBoxKey.defaultDecode,
            defaultValue: VideoDecodeFormats.values.last.code))!;
        firstVideo = videoList
            .firstWhere((i) => i.codecs!.startsWith(currentDecodeFormats.code));
      }
    }
    videoUrl = firstVideo.baseUrl!;

    /// 根据currentAudioQa 重新设置audioUrl
    if (currentAudioQa != null) {
      AudioItem firstAudio = data.dash!.audio!.firstWhere(
        (i) => i.id == currentAudioQa!.code,
        orElse: () => data.dash!.audio!.first,
      );
      audioUrl = firstAudio.baseUrl ?? '';
    }

    playerInit();
  }

  Future playerInit({
    video,
    audio,
    seekToTime,
    duration,
    bool autoplay = true,
  }) async {
    /// 设置/恢复 屏幕亮度
    if (brightness != null) {
      ScreenBrightness().setScreenBrightness(brightness!);
    } else {
      ScreenBrightness().resetScreenBrightness();
    }
    await plPlayerController.setDataSource(
      DataSource(
        videoSource: video ?? videoUrl,
        audioSource: audio ?? audioUrl,
        type: DataSourceType.network,
        httpHeaders: {
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
          'referer': HttpString.baseUrl
        },
      ),
      // 硬解
      enableHA: enableHA.value,
      seekTo: seekToTime ?? defaultST,
      duration: duration ?? Duration(milliseconds: data.timeLength ?? 0),
      // 宽>高 水平 否则 垂直
      direction: (firstVideo.width! - firstVideo.height!) > 0
          ? 'horizontal'
          : 'vertical',
      // 默认1倍速
      speed: 1.0,
      bvid: bvid,
      cid: cid.value,
      enableHeart: enableHeart,
      isFirstTime: isFirstTime,
      autoplay: autoplay,
    );
  }

  // 视频链接
  Future queryVideoUrl() async {
    var result = await VideoHttp.videoUrl(cid: cid.value, bvid: bvid);
    if (result['status']) {
      data = result['data'];

      List<VideoItem> allVideosList = data.dash!.video!;

      try {
        // 当前可播放的最高质量视频
        int currentHighVideoQa = allVideosList.first.quality!.code;
        // 使用预设的画质 ｜ 当前可用的最高质量
        int cacheVideoQa = setting.get(SettingBoxKey.defaultVideoQa,
            defaultValue: currentHighVideoQa);
        int resVideoQa = currentHighVideoQa;
        if (cacheVideoQa <= currentHighVideoQa) {
          // 如果预设的画质低于当前最高
          List<int> numbers = data.acceptQuality!
              .where((e) => e <= currentHighVideoQa)
              .toList();
          resVideoQa = Utils.findClosestNumber(cacheVideoQa, numbers);
        }
        currentVideoQa = VideoQualityCode.fromCode(resVideoQa)!;

        /// 取出符合当前画质的videoList
        List<VideoItem> videosList =
            allVideosList.where((e) => e.quality!.code == resVideoQa).toList();

        /// 优先顺序 设置中指定解码格式 -> 当前可选的首个解码格式
        List<FormatItem> supportFormats = data.supportFormats!;
        // 根据画质选编码格式
        List supportDecodeFormats =
            supportFormats.firstWhere((e) => e.quality == resVideoQa).codecs!;
        // 默认从设置中取AVC
        currentDecodeFormats = VideoDecodeFormatsCode.fromString(setting.get(
            SettingBoxKey.defaultDecode,
            defaultValue: VideoDecodeFormats.values.last.code))!;
        try {
          // 当前视频没有对应格式返回第一个
          bool flag = false;
          for (var i in supportDecodeFormats) {
            if (i.startsWith(currentDecodeFormats.code)) {
              flag = true;
            }
          }
          currentDecodeFormats = flag
              ? currentDecodeFormats
              : VideoDecodeFormatsCode.fromString(supportDecodeFormats.first)!;
        } catch (e) {
          print(e);
        }

        /// 取出符合当前解码格式的videoItem
        try {
          firstVideo = videosList.firstWhere(
              (e) => e.codecs!.startsWith(currentDecodeFormats.code));
        } catch (_) {
          firstVideo = videosList.first;
        }
        videoUrl = firstVideo.baseUrl!;
      } catch (err) {
        print(err);
      }

      /// 优先顺序 设置中指定质量 -> 当前可选的最高质量
      late AudioItem? firstAudio;
      List<AudioItem> audiosList = data.dash!.audio!;

      try {
        int resultAudioQa = setting.get(SettingBoxKey.defaultAudioQa,
            defaultValue: AudioQuality.hiRes.code);

        if (data.dash!.dolby?.audio?.isNotEmpty == true) {
          // 杜比
          audiosList.insert(0, data.dash!.dolby!.audio!.first);
        }

        if (data.dash!.flac?.audio != null) {
          // 无损
          audiosList.insert(0, data.dash!.flac!.audio!);
        }

        if (audiosList.isNotEmpty) {
          List<int> numbers = audiosList.map((map) => map.id!).toList();
          int closestNumber = Utils.findClosestNumber(resultAudioQa, numbers);
          if (!numbers.contains(resultAudioQa)) {
            closestNumber = 30280;
          }
          firstAudio = audiosList.firstWhere((e) => e.id == closestNumber);
        }
      } catch (e) {
        print(e);
      }

      audioUrl = firstAudio!.baseUrl ?? '';
      //
      if (firstAudio.id != null) {
        currentAudioQa = AudioQualityCode.fromCode(firstAudio.id!)!;
      }
      defaultST = Duration(milliseconds: data.lastPlayTime!);
      if (autoPlay.value) {
        await playerInit();
        isShowCover.value = false;
      }
    } else {
      if (result['code'] == -404) {
        isShowCover.value = false;
      }
      SmartDialog.showToast(result['msg'].toString());
    }
    return result;
  }
}
