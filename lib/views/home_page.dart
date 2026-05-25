import 'package:flutter/material.dart';
import '../models/drone_package.dart';
import '../models/battery.dart';
import '../models/action_log.dart';
import '../repositories/fleet_repository.dart';
import '../repositories/admin_repository.dart';
import 'add_package_dialog.dart';
import 'register_battery_dialog.dart';
import 'package_detail_screen.dart';
import 'admin/admin_management_screen.dart';
import '../version.dart';

/// 專案主要首頁，整合 Material 3 響應式佈局與 Firestore 即時資料流
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FleetRepository _repository = FleetRepository();
  final AdminRepository _adminRepository = AdminRepository();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 以 600dp 作為手機與平板/桌面的斷點
        final isMobile = constraints.maxWidth <= 600;

        return Scaffold(
          body: Row(
            children: [
              // 平板/桌面端：展示左側 NavigationRail
              if (!isMobile) ...[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2),
                      label: Text('套裝總表'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.battery_charging_full_outlined),
                      selectedIcon: Icon(Icons.battery_charging_full),
                      label: Text('電池管理'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('任務軌跡'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      selectedIcon: Icon(Icons.admin_panel_settings),
                      label: Text('後台管理'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
              ],
              // 主要內容區
              Expanded(
                child: _selectedIndex == 3
                    ? AdminManagementScreen(repository: _adminRepository)
                    : CustomScrollView(
                        slivers: [
                          // M3 風格的頂部導航大標題
                          SliverAppBar.large(
                            title: const Text('極光機隊管理系統 $appVersion'),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.account_circle_outlined),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          // 根據目前選擇的頁籤載入對應內容
                          _buildSliverContent(isMobile),
                        ],
                      ),
              ),
            ],
          ),
          // 手機端：展示底部 M3 NavigationBar
          bottomNavigationBar: isMobile
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2),
                      label: '套裝',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.battery_charging_full_outlined),
                      selectedIcon: Icon(Icons.battery_charging_full),
                      label: '電池',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: '軌跡',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      selectedIcon: Icon(Icons.admin_panel_settings),
                      label: '後台',
                    ),
                  ],
                )
              : null,
          // 根據分頁顯示不同的 FAB
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<DronePackage>(
            context: context,
            builder: (context) => AddPackageDialog(repository: _repository),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('登錄新套裝'),
      );
    } else if (_selectedIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => RegisterBatteryDialog(repository: _repository),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('登錄新電池'),
      );
    }
    return null;
  }

  /// 根據當前選擇的分頁，渲染對應的 Sliver 內容
  Widget _buildSliverContent(bool isMobile) {
    switch (_selectedIndex) {
      case 0:
        return _buildPackageList(isMobile);
      case 1:
        return _buildBatteryList(isMobile);
      case 2:
        return _buildActionLogs(isMobile);
      default:
        return const SliverFillRemaining(
          child: Center(child: Text('查無此分頁')),
        );
    }
  }

  // ==========================================
  // 【套裝總表】Sliver 渲染邏輯
  // ==========================================
  Widget _buildPackageList(bool isMobile) {
    return StreamBuilder<List<DronePackage>>(
      stream: _repository.getPackagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(child: Center(child: Text('載入失敗: ${snapshot.error}')));
        }
        final packages = snapshot.data ?? [];
        if (packages.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('尚無套裝資料，請點擊右下角新增')));
        }

        if (isMobile) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPackageCard(packages[index]),
                  );
                },
                childCount: packages.length,
              ),
            ),
          );
        } else {
          return SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPackageCard(packages[index]);
                },
                childCount: packages.length,
              ),
            ),
          );
        }
      },
    );
  }

  /// 獨立的 Package Card，使用 Material 3 Filled Card
  Widget _buildPackageCard(DronePackage package) {
    return Card.filled(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // 點擊卡片跳轉至 M3 配置細節面板
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PackageDetailScreen(
                package: package,
                repository: _repository,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package.tacticalName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      package.modelType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 16, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '設備: ${package.currentDroneSn != null ? 1 : 0} 飛機, ${package.currentRcSn != null ? 1 : 0} 遙控',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    package.currentKeeper,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 【電池管理】Sliver 渲染邏輯
  // ==========================================
  Widget _buildBatteryList(bool isMobile) {
    return StreamBuilder<List<Battery>>(
      stream: _repository.getBatteriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(child: Center(child: Text('載入失敗: ${snapshot.error}')));
        }
        final batteries = snapshot.data ?? [];
        if (batteries.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('尚無電池資料')));
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 8,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final battery = batteries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.battery_std,
                            size: 40,
                            color: battery.healthStatus.contains('膨脹')
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  battery.batteryModel,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text('序號: ${battery.documentId}'),
                                Text('循環次數: ${battery.cycleCount} 次'),
                                Text(
                                  '狀態: ${battery.healthStatus}',
                                  style: TextStyle(
                                    color: battery.healthStatus.contains('膨脹')
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: battery.healthStatus.contains('膨脹')
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (battery.currentPackageId != null)
                            Chip(
                              label: const Text('已在套裝內'),
                              avatar: const Icon(Icons.inventory_2, size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: batteries.length,
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 【任務軌跡/動態時間軸】Sliver 渲染邏輯
  // ==========================================
  Widget _buildActionLogs(bool isMobile) {
    return StreamBuilder<List<ActionLog>>(
      stream: _repository.getAllActionLogsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(child: Center(child: Text('載入失敗: ${snapshot.error}')));
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('尚無任務軌跡')));
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 8,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = logs[index];
                final eventColor = _getEventColor(log.eventType);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 左側時間軸線條與圓點
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: eventColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 右側卡片內容
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getEventName(log.eventType),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: eventColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${log.timestamp.month}/${log.timestamp.day} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(log.description),
                                  if (log.cost > 0) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '維修花費: \$${log.cost.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (log.droneSn != null)
                                        ActionChip(
                                          label: Text(log.droneSn!),
                                          onPressed: () {},
                                        ),
                                      ...log.aiTags.map(
                                        (tag) => Chip(
                                          label: Text(tag),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: logs.length,
            ),
          ),
        );
      },
    );
  }

  /// 輔助方法：獲取事件代表顏色
  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'crash':
        return Colors.red;
      case 'repair':
        return Colors.orange;
      case 'battery_transfer':
        return Colors.blue;
      case 'health_check':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// 輔助方法：獲取事件繁體中文名稱
  String _getEventName(String eventType) {
    switch (eventType) {
      case 'crash':
        return '💥 異常墜毀';
      case 'repair':
        return '🔧 設備維修';
      case 'battery_transfer':
        return '🔋 電池調度';
      case 'health_check':
        return '✅ 健康檢查';
      default:
        return '📝 一般紀錄';
    }
  }
}
