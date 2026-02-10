import 'package:flutter/material.dart';

class MapResizableTabSheetController {
  void Function()? _expandToFull;
  void Function()? _collapseToPeek;

  void _attach({
    required void Function() expandToFull,
    required void Function() collapseToPeek,
  }) {
    _expandToFull = expandToFull;
    _collapseToPeek = collapseToPeek;
  }

  void _detach() {
    _expandToFull = null;
    _collapseToPeek = null;
  }

  void expandToFull() => _expandToFull?.call();
  void collapseToPeek() => _collapseToPeek?.call();
}

class MapResizableTabSheet extends StatefulWidget {
  const MapResizableTabSheet({
    super.key,
    required this.map,
    required this.tabChildren,
    this.controller,
    this.onFullChanged,
  });

  // 上方共用的地圖（會被擠壓縮小）
  final Widget map;

  // 每個 tab 在 sheet 內的內容
  final List<Widget> tabChildren;

  // 外部控制（滿版 / 回 peek）
  final MapResizableTabSheetController? controller;

  // 回報是否滿版（讓 AppBar icon 切換）
  final ValueChanged<bool>? onFullChanged;

  @override
  State<MapResizableTabSheet> createState() => MapResizableTabSheetState();
}

class MapResizableTabSheetState extends State<MapResizableTabSheet> with SingleTickerProviderStateMixin {
  // ===== 固定 UI 規格：統一，不對外開放 =====
  static const double _cornerRadius = 24;
  static const double _handleHeight = 44;

  static const Duration _snapDuration = Duration(milliseconds: 260);
  static const double _flickVelocityThreshold = 700;

  static const double _midSnap = 0.5;
  static const double _maxSnap = 1.0;

  // 滿版時吞 handle/圓角的開始比例
  static const double _chromeStart = 0.88;

  // header 尚未量到時的保底高度（避免一開始 min 太小）
  static const double _headerFallback = 56.0;

  late double _sheetHeight;
  late final AnimationController _controller;

  Animation<double>? _anim;
  bool _isSnapping = false;

  double? _lastTotalH;
  bool? _lastIsFull;
  bool _isDragging = false;

  bool _didInitHeight = false;

  // 每個 tab 的 header 高度
  late List<double> _tabHeaderHeights;
  int _currentTabIndex = 0;
  double _lastMinSheetPx = 0;

  TabController? _tabController;

  bool get isFullNow => _lastIsFull == true;

  // 給外部 tab view 回報 header 高度用
  void setHeaderHeight(int tabIndex, double height) {
    if (tabIndex < 0) return;
    if (tabIndex >= _tabHeaderHeights.length) return;

    final prev = _tabHeaderHeights[tabIndex];
    if ((prev - height).abs() <= 0.5) return;

    setState(() => _tabHeaderHeights[tabIndex] = height);
  }

  /// 這裡適合用在有手動在header增加任何widget時
  /// 可以手動額外增加高度
  /// 但目前的設計可以符合現有設計
  /// 暫時先增加，以便隨時動態調整
  static const double _peekExtraPx = 1;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // 初始先給個合理值，真正 peek 會在第一次 layout 用 minSheetPx 校正
    _sheetHeight = _handleHeight + _headerFallback;

    _tabHeaderHeights = List.filled(widget.tabChildren.length, 0);

    widget.controller?._attach(
      expandToFull: expandToFull,
      collapseToPeek: collapseToPeek,
    );
  }

  @override
  void didUpdateWidget(covariant MapResizableTabSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(
        expandToFull: expandToFull,
        collapseToPeek: collapseToPeek,
      );
    }

    if (oldWidget.tabChildren.length != widget.tabChildren.length) {
      _tabHeaderHeights = List.filled(widget.tabChildren.length, 0);
      _currentTabIndex = _currentTabIndex.clamp(0, widget.tabChildren.length - 1);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tc = DefaultTabController.of(context);
    if (_tabController == tc) return;

    _tabController?.removeListener(_onTabChanged);
    _tabController = tc;
    _tabController?.addListener(_onTabChanged);

    // 同步一次 index（避免第一次進來不同步）
    _currentTabIndex = _tabController?.index ?? 0;
  }

  void _onTabChanged() {
    // indexIsChanging 會在動畫過程中多次觸發
    final idx = _tabController?.index ?? 0;
    if (idx == _currentTabIndex) return;
    setState(() => _currentTabIndex = idx);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  void expandToFull() {
    final totalH = _lastTotalH;
    if (totalH == null) return;
    _animateTo(totalH * _maxSnap);
  }

  void collapseToPeek() {
    final totalH = _lastTotalH;
    if (totalH == null) return;

    final maxSheet = totalH * _maxSnap;
    final headerH = _currentHeaderHeight();
    final minSheetPx = (_handleHeight + headerH + _peekExtraPx).clamp(0.0, maxSheet);

    _animateTo(minSheetPx);
  }

  double _currentHeaderHeight() {
    if (_tabHeaderHeights.isEmpty) return _headerFallback;
    if (_currentTabIndex < 0 || _currentTabIndex >= _tabHeaderHeights.length) {
      return _headerFallback;
    }
    final h = _tabHeaderHeights[_currentTabIndex];
    return h > 0 ? h : _headerFallback;
  }

  void _stopSnap() {
    if (_isSnapping) {
      _controller.stop();
      _isSnapping = false;
    }
  }

  void _animateTo(double targetHeight) {
    _stopSnap();

    final begin = _sheetHeight;
    if ((begin - targetHeight).abs() < 0.5) return;

    _isSnapping = true;
    _controller.duration = _snapDuration;

    _anim = Tween<double>(begin: begin, end: targetHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )
      ..addListener(() => setState(() => _sheetHeight = _anim!.value))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          _isSnapping = false;
        }
      });

    _controller
      ..reset()
      ..forward();
  }

  double _nearestSnapRatio(double ratio, List<double> snaps) {
    double best = snaps.first;
    double bestDist = (ratio - best).abs();
    for (final r in snaps) {
      final d = (ratio - r).abs();
      if (d < bestDist) {
        bestDist = d;
        best = r;
      }
    }
    return best;
  }

  double _nextHigherSnapRatio(double ratio, List<double> snaps) {
    for (final r in snaps) {
      if (r > ratio + 1e-6) return r;
    }
    return snaps.last;
  }

  double _nextLowerSnapRatio(double ratio, List<double> snaps) {
    for (int i = snaps.length - 1; i >= 0; i--) {
      final r = snaps[i];
      if (r < ratio - 1e-6) return r;
    }
    return snaps.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        _lastTotalH = totalH;

        final maxSheet = totalH * _maxSnap;

        // 用「目前 tab 的 headerHeight」算 minSheetPx
        final headerH = _currentHeaderHeight();
        final minSheetPx = (_handleHeight + headerH + _peekExtraPx).clamp(0.0, maxSheet);
        final minR = (minSheetPx / totalH).clamp(0.0, 1.0);

        // 第一次進來就鎖在 peek（依當下 tab header）
        if (!_didInitHeight) {
          _sheetHeight = minSheetPx;
          _didInitHeight = true;
          _lastMinSheetPx = minSheetPx;
        }

        // header 變高時（Wrap 多一行），要自動抬高，避免切到 header
        if (minSheetPx > _lastMinSheetPx + 0.5 && _sheetHeight < minSheetPx) {
          _sheetHeight = minSheetPx;
        }
        _lastMinSheetPx = minSheetPx;

        // 保護：避免內部高度跑出範圍
        if (_sheetHeight < minSheetPx) _sheetHeight = minSheetPx;
        if (_sheetHeight > maxSheet) _sheetHeight = maxSheet;

        final sheetH = _sheetHeight.clamp(minSheetPx, maxSheet);
        final mapH = (totalH - sheetH).clamp(0.0, totalH);

        final effectiveSnaps = <double>{minR, _midSnap, _maxSnap}.toList()..sort();

        final ratioToFull = (sheetH / maxSheet).clamp(0.0, 1.0);
        final t = ((ratioToFull - _chromeStart) / (1 - _chromeStart)).clamp(0.0, 1.0);

        final chrome = _isDragging ? 1.0 : (1.0 - t);
        final radius = _cornerRadius * chrome;

        final isFull = sheetH >= maxSheet - 0.5;
        if (_lastIsFull != isFull) {
          _lastIsFull = isFull;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.onFullChanged?.call(isFull);
          });
        }

        return Column(
          children: [
            SizedBox(height: mapH, child: widget.map),
            SizedBox(
              height: sheetH,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                  boxShadow: chrome <= 0.02
                      ? const []
                      : const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 20,
                            offset: Offset(0, -6),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                  child: Column(
                    children: [
                      // 同步縮到 0（不會兩段跳）
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: chrome,
                          child: Opacity(
                            opacity: chrome,
                            child: IgnorePointer(
                              ignoring: !_isDragging && t > 0.0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onVerticalDragStart: (_) {
                                  _stopSnap();
                                  setState(() => _isDragging = true);
                                },
                                onVerticalDragUpdate: (details) {
                                  setState(() {
                                    _sheetHeight = (_sheetHeight - details.delta.dy).clamp(minSheetPx, maxSheet);
                                  });
                                },
                                onVerticalDragEnd: (details) {
                                  setState(() => _isDragging = false);

                                  final ratio = (_sheetHeight / totalH).clamp(0.0, 1.0);
                                  final v = details.primaryVelocity ?? 0.0;

                                  final targetRatio = (v.abs() >= _flickVelocityThreshold)
                                      ? (v < 0
                                          ? _nextHigherSnapRatio(ratio, effectiveSnaps)
                                          : _nextLowerSnapRatio(ratio, effectiveSnaps))
                                      : _nearestSnapRatio(ratio, effectiveSnaps);

                                  _animateTo(targetRatio * totalH);
                                },
                                onVerticalDragCancel: () {
                                  setState(() => _isDragging = false);
                                },
                                child: SizedBox(
                                  height: _handleHeight,
                                  child: Center(
                                    child: Container(
                                      width: 56,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0x40000000),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 保留 Expanded（tab content）
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: widget.tabChildren,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
