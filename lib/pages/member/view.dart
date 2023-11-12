import 'dart:async';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/pages/member/archive/view.dart';
import 'package:pilipala/pages/member/dynamic/index.dart';
import 'package:pilipala/pages/member/index.dart';
import 'package:pilipala/utils/utils.dart';

import 'widgets/profile.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage>
    with SingleTickerProviderStateMixin {
  late String heroTag;
  late MemberController _memberController;
  Future? _futureBuilderFuture;
  final ScrollController _extendNestCtr = ScrollController();
  late TabController _tabController;
  final StreamController<bool> appbarStream = StreamController<bool>();
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _futureBuilderFuture = _memberController.getInfo();
    _extendNestCtr.addListener(
      () {
        double offset = _extendNestCtr.position.pixels;
        if (offset > 230) {
          appbarStream.add(true);
        } else {
          appbarStream.add(false);
        }
      },
    );
  }

  @override
  void dispose() {
    _extendNestCtr.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      body: ExtendedNestedScrollView(
        controller: _extendNestCtr,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: false,
              primary: true,
              elevation: 0,
              scrolledUnderElevation: 1,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: 290,
              titleSpacing: 0,
              title: StreamBuilder(
                stream: appbarStream.stream,
                initialData: false,
                builder: (context, AsyncSnapshot snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.data ? 1 : 0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Obx(
                              () => NetworkImgLayer(
                                width: 35,
                                height: 35,
                                type: 'avatar',
                                src: _memberController.face.value,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(
                              () => Text(
                                _memberController.memberInfo.value.name ?? '',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
              actions: [
                IconButton(
                  onPressed: () => Get.toNamed(
                      '/memberSearch?mid=${Get.parameters['mid']}&uname=${_memberController.memberInfo.value.name!}'),
                  icon: const Icon(Icons.search_outlined),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    if (_memberController.ownerMid !=
                        _memberController.mid) ...[
                      PopupMenuItem(
                        onTap: () => _memberController.blockUser(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.block, size: 19),
                            const SizedBox(width: 10),
                            Text(_memberController.attribute.value != 128
                                ? '加入黑名单'
                                : '移除黑名单'),
                          ],
                        ),
                      )
                    ],
                    PopupMenuItem(
                      onTap: () => _memberController.shareUser(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.share_outlined, size: 19),
                          const SizedBox(width: 10),
                          Text(_memberController.ownerMid !=
                                  _memberController.mid
                              ? '分享UP主'
                              : '分享我的主页'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Obx(
                      () => _memberController.face.value != ''
                          ? Positioned.fill(
                              bottom: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: NetworkImage(
                                        _memberController.face.value),
                                    alignment: Alignment.topCenter,
                                    isAntiAlias: true,
                                  ),
                                ),
                                foregroundDecoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.44),
                                      Theme.of(context).colorScheme.background,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.46],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 20,
                      child: Container(
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                    profileWidget(),
                  ],
                ),
              ),
            ),
          ];
        },
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        onlyOneScrollInBody: true,
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TabBar(controller: _tabController, tabs: const [
                Tab(text: '主页'),
                Tab(text: '动态'),
                Tab(text: '投稿'),
              ]),
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: [
                const Text('主页'),
                MemberDynamicPanel(mid: mid),
                ArchivePanel(mid: mid),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget profileWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map data = snapshot.data!;
            if (data['status']) {
              return Obx(
                () => Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profile(_memberController),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Flexible(
                                child: Text(
                              _memberController.memberInfo.value.name!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )),
                            const SizedBox(width: 2),
                            if (_memberController.memberInfo.value.sex == '女')
                              const Icon(
                                FontAwesomeIcons.venus,
                                size: 14,
                                color: Colors.pink,
                              ),
                            if (_memberController.memberInfo.value.sex == '男')
                              const Icon(
                                FontAwesomeIcons.mars,
                                size: 14,
                                color: Colors.blue,
                              ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/lv/lv${_memberController.memberInfo.value.level}.png',
                              height: 11,
                            ),
                            const SizedBox(width: 6),
                            if (_memberController
                                        .memberInfo.value.vip!.status ==
                                    1 &&
                                _memberController.memberInfo.value.vip!
                                        .label!['img_label_uri_hans'] !=
                                    '') ...[
                              Image.network(
                                _memberController.memberInfo.value.vip!
                                    .label!['img_label_uri_hans'],
                                height: 20,
                              ),
                            ] else if (_memberController
                                        .memberInfo.value.vip!.status ==
                                    1 &&
                                _memberController.memberInfo.value.vip!
                                        .label!['img_label_uri_hans_static'] !=
                                    '') ...[
                              Image.network(
                                _memberController.memberInfo.value.vip!
                                    .label!['img_label_uri_hans_static'],
                                height: 20,
                              ),
                            ]
                          ],
                        ),
                        if (_memberController
                                .memberInfo.value.official!['title'] !=
                            '') ...[
                          const SizedBox(height: 6),
                          Text.rich(
                            maxLines: 2,
                            TextSpan(
                              text: _memberController
                                          .memberInfo.value.official!['role'] ==
                                      1
                                  ? '个人认证：'
                                  : '企业认证：',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              children: [
                                TextSpan(
                                  text: _memberController
                                      .memberInfo.value.official!['title'],
                                ),
                              ],
                            ),
                            softWrap: true,
                          ),
                        ],
                        const SizedBox(height: 4),
                        if (_memberController.memberInfo.value.sign != '')
                          SelectableText(
                            _memberController.memberInfo.value.sign!,
                            maxLines: _memberController
                                        .memberInfo.value.official!['title'] !=
                                    ''
                                ? 1
                                : 2,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: SelectableText(_memberController
                                        .memberInfo.value.sign!),
                                  );
                                },
                              );
                            },
                          )
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          } else {
            // 骨架屏
            return profile(_memberController, loadingStatus: true);
          }
        },
      ),
    );
  }
}
