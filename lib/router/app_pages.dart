// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/pages/about/index.dart';
import 'package:pilipala/pages/blacklist/index.dart';
import 'package:pilipala/pages/dynamics/deatil/index.dart';
import 'package:pilipala/pages/dynamics/index.dart';
import 'package:pilipala/pages/fan/index.dart';
import 'package:pilipala/pages/fav/index.dart';
import 'package:pilipala/pages/favDetail/index.dart';
import 'package:pilipala/pages/follow/index.dart';
import 'package:pilipala/pages/history/index.dart';
import 'package:pilipala/pages/home/index.dart';
import 'package:pilipala/pages/hot/index.dart';
import 'package:pilipala/pages/html/index.dart';
import 'package:pilipala/pages/later/index.dart';
import 'package:pilipala/pages/liveRoom/view.dart';
import 'package:pilipala/pages/member/index.dart';
import 'package:pilipala/pages/member_search/index.dart';
import 'package:pilipala/pages/preview/index.dart';
import 'package:pilipala/pages/search/index.dart';
import 'package:pilipala/pages/searchResult/index.dart';
import 'package:pilipala/pages/setting/extra_setting.dart';
import 'package:pilipala/pages/setting/pages/color_select.dart';
import 'package:pilipala/pages/setting/pages/display_mode.dart';
import 'package:pilipala/pages/setting/pages/font_size_select.dart';
import 'package:pilipala/pages/setting/play_setting.dart';
import 'package:pilipala/pages/setting/privacy_setting.dart';
import 'package:pilipala/pages/setting/style_setting.dart';
import 'package:pilipala/pages/video/detail/index.dart';
import 'package:pilipala/pages/video/detail/replyReply/index.dart';
import 'package:pilipala/pages/webview/index.dart';
import 'package:pilipala/pages/setting/index.dart';
import 'package:pilipala/pages/media/index.dart';
import 'package:pilipala/utils/storage.dart';

import '../pages/history_search/index.dart';

Box setting = GStrorage.setting;
bool iosTransition =
    setting.get(SettingBoxKey.iosTransition, defaultValue: false);

class Routes {
  static final List<GetPage> getPages = [
    // 首页(推荐)
    CustomGetPage(name: '/', page: () => HomePage()),
    // 热门
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    CustomGetPage(name: '/video', page: () => const VideoDetailPage()),
    // 图片预览
    // GetPage(
    //   name: '/preview',
    //   page: () => const ImagePreview(),
    //   transition: Transition.fade,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   showCupertinoParallax: false,
    // ),
    //
    CustomGetPage(name: '/webview', page: () => const WebviewPage()),
    // 设置
    CustomGetPage(name: '/setting', page: () => const SettingPage()),
    //
    CustomGetPage(name: '/media', page: () => const MediaPage()),
    //
    CustomGetPage(name: '/fav', page: () => const FavPage()),
    //
    CustomGetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    CustomGetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    CustomGetPage(name: '/history', page: () => const HistoryPage()),
    // 搜索页面
    CustomGetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    CustomGetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    CustomGetPage(name: '/dynamics', page: () => const DynamicsPage()),
    // 动态详情
    CustomGetPage(
        name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    CustomGetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    CustomGetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    CustomGetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    CustomGetPage(name: '/member', page: () => const MemberPage()),
    CustomGetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    // 二级回复
    CustomGetPage(
        name: '/replyReply', page: () => const VideoReplyReplyPanel()),

    // 播放设置
    CustomGetPage(name: '/playSetting', page: () => const PlaySetting()),
    // 外观设置
    CustomGetPage(name: '/styleSetting', page: () => const StyleSetting()),
    // 隐私设置
    CustomGetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    // 其他设置
    CustomGetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    //
    CustomGetPage(name: '/blackListPage', page: () => const BlackListPage()),
    CustomGetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    CustomGetPage(
        name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    CustomGetPage(
        name: '/displayModeSetting', page: () => const SetDiaplayMode()),
    // 关于
    CustomGetPage(name: '/about', page: () => const AboutPage()),
    //
    CustomGetPage(name: '/htmlRender', page: () => const HtmlRenderPage()),
    // 历史记录搜索
    CustomGetPage(
        name: '/historySearch', page: () => const HistorySearchPage()),
  ];
}

class CustomGetPage extends GetPage {
  bool? fullscreen = false;

  CustomGetPage({
    name,
    page,
    this.fullscreen,
    transitionDuration,
  }) : super(
          name: name,
          page: page,
          curve: Curves.linear,
          transition: iosTransition ? Transition.cupertino : Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          transitionDuration: transitionDuration,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
}
