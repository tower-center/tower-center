import 'package:flutter/material.dart';
import '../models/drone_package.dart';
import '../models/battery.dart';
import '../models/action_log.dart';
import '../models/drone.dart';
import '../models/remote_controller.dart';
import '../repositories/fleet_repository.dart';
import '../repositories/admin_repository.dart';
import 'add_package_dialog.dart';
import 'register_battery_dialog.dart';
import 'package_detail_screen.dart';
import 'asset_detail_screen.dart';
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
  String? _selectedBatteryModelTab;
  String _selectedInventoryTab = 'drones';
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
                      label: Text('空拍便攜盒總表'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.warehouse_outlined),
                      selectedIcon: Icon(Icons.warehouse),
                      label: Text('庫存物資'),
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
                child: _selectedIndex == 4
                    ? AdminManagementScreen(repository: _adminRepository)
                    : CustomScrollView(
                        slivers: [
                          // M3 風格的頂部導航大標題
                          SliverAppBar.large(
                            title: const Text('空拍機隊管理系統 $appVersion'),
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
                      icon: Icon(Icons.warehouse_outlined),
                      selectedIcon: Icon(Icons.warehouse),
                      label: '庫存',
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
    } else if (_selectedIndex == 2) {
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
        return _buildInventoryOverview(isMobile);
      case 2:
        return _buildBatteryList(isMobile);
      case 3:
        return _buildActionLogs(isMobile);
      default:
        return const SliverFillRemaining(
          child: Center(child: Text('查無此分頁')),
        );
    }
  }

  // ==========================================
  // 【庫存物資總覽】Sliver 渲染邏輯
  // ==========================================
  Widget _buildInventoryOverview(bool isMobile) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分頁選擇 ChoiceChips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.flight, size: 16),
                    label: const Text('空拍機 ✈️', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedInventoryTab == 'drones',
                    onSelected: (val) {
                      if (val) setState(() => _selectedInventoryTab = 'drones');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.settings_remote, size: 16),
                    label: const Text('遙控器 🎮', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedInventoryTab == 'rcs',
                    onSelected: (val) {
                      if (val) setState(() => _selectedInventoryTab = 'rcs');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.battery_std, size: 16),
                    label: const Text('智能電池 🔋', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedInventoryTab == 'batteries',
                    onSelected: (val) {
                      if (val) setState(() => _selectedInventoryTab = 'batteries');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 物資內容展示
            _buildInventoryGrid(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryGrid(bool isMobile) {
    if (_selectedInventoryTab == 'drones') {
      return StreamBuilder<List<Drone>>(
        stream: _repository.getUnassignedDronesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
          }
          final drones = snapshot.data ?? [];
          if (drones.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: Text('目前沒有空閒的飛機在庫存中', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.5,
            ),
            itemCount: drones.length,
            itemBuilder: (context, index) {
              final drone = drones[index];
              return Card.outlined(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AssetDetailScreen(
                          assetId: drone.documentId,
                          type: 'drone',
                          repository: _repository,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          drone.documentId,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('型號: ${drone.modelType}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (drone.serialNumber != null)
                          Text('S/N: ${drone.serialNumber}', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('狀態:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              drone.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: drone.status == '正常' ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else if (_selectedInventoryTab == 'rcs') {
      return StreamBuilder<List<RemoteController>>(
        stream: _repository.getUnassignedRemoteControllersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
          }
          final rcs = snapshot.data ?? [];
          if (rcs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: Text('目前沒有空閒的遙控器在庫存中', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.5,
            ),
            itemCount: rcs.length,
            itemBuilder: (context, index) {
              final rc = rcs[index];
              return Card.outlined(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AssetDetailScreen(
                          assetId: rc.documentId,
                          type: 'rc',
                          repository: _repository,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rc.documentId,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('型號: ${rc.rcType}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (rc.serialNumber != null)
                          Text('S/N: ${rc.serialNumber}', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('狀態:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              rc.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: rc.status == '正常' ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<List<Battery>>(
        stream: _repository.getUnassignedBatteriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
          }
          final batteries = snapshot.data ?? [];
          if (batteries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: Text('目前沒有空閒的電池在庫存中', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 3 : 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 0.8 : 1.2,
            ),
            itemCount: batteries.length,
            itemBuilder: (context, index) {
              final battery = batteries[index];
              final isWarning = battery.healthStatus.contains('膨脹');

              return Card.outlined(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isWarning ? Colors.red.withOpacity(0.5) : Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AssetDetailScreen(
                          assetId: battery.documentId,
                          type: 'battery',
                          repository: _repository,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          battery.tagName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isWarning ? Colors.red : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          battery.batteryModel,
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('循環:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('${battery.cycleCount} 次', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('狀態:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Expanded(
                              child: Text(
                                battery.healthStatus,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : null),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  // ==========================================
  // 【空拍便攜盒總表】Sliver 渲染邏輯
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
                childAspectRatio: 0.82,
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
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // 點擊大卡片跳轉至便攜盒配置細節面板
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
            children: [
              // 1. 標題與保管人
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
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '保管人: ${package.currentKeeper}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // 2. 實體設備微型卡區 (飛機與遙控器)
              const Text('🔌 實體設備:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                children: [
                  // 飛機卡片
                  Expanded(
                    child: _buildNestedAssetCard(
                      icon: Icons.flight,
                      label: package.currentDroneSn != null ? '飛機 1' : '未放飛機',
                      subLabel: package.currentDroneSn ?? '無設備',
                      isAssigned: package.currentDroneSn != null,
                      onTap: package.currentDroneSn != null
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AssetDetailScreen(
                                    assetId: package.currentDroneSn!,
                                    type: 'drone',
                                    repository: _repository,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 遙控器卡片
                  Expanded(
                    child: _buildNestedAssetCard(
                      icon: Icons.settings_remote,
                      label: package.currentRcSn != null ? '遙控 1' : '未放遙控',
                      subLabel: package.currentRcSn ?? '無設備',
                      isAssigned: package.currentRcSn != null,
                      onTap: package.currentRcSn != null
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AssetDetailScreen(
                                    assetId: package.currentRcSn!,
                                    type: 'rc',
                                    repository: _repository,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. 智能電池微型晶片區
              const Text('🔋 智能電池:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              StreamBuilder<List<Battery>>(
                stream: _repository.getPackageBatteriesStream(package.documentId),
                builder: (context, snapshot) {
                  final batteries = snapshot.data ?? [];
                  if (batteries.isEmpty) {
                    return const Text('無電池', style: TextStyle(fontSize: 12, color: Colors.grey));
                  }
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: batteries.map((b) => Material(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AssetDetailScreen(
                                assetId: b.documentId,
                                type: 'battery',
                                repository: _repository,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.battery_std, size: 12, color: Colors.teal),
                              const SizedBox(width: 2),
                              Text(
                                b.tagName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 4. 配件 Wrap 清單 (完全展開)
              const Text('🔧 配件清單:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              if (package.accessories.isEmpty)
                const Text('無配件', style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: package.accessories.entries.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${e.key} x${e.value}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 嵌套在卡片中的微型設備卡片
  Widget _buildNestedAssetCard({
    required IconData icon,
    required String label,
    required String subLabel,
    required bool isAssigned,
    VoidCallback? onTap,
  }) {
    return Material(
      color: isAssigned 
          ? Theme.of(context).colorScheme.surfaceContainerLowest 
          : Theme.of(context).colorScheme.surfaceDim.withOpacity(0.3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAssigned 
                  ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.7) 
                  : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: isAssigned ? Theme.of(context).colorScheme.primary : Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAssigned ? Colors.black87 : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isAssigned ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                  fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

        final models = batteries.map((b) => b.batteryModel).toSet().toList()..sort();
        final currentTab = (_selectedBatteryModelTab != null && models.contains(_selectedBatteryModelTab)) 
            ? _selectedBatteryModelTab! 
            : models.first;

        final filteredBatteries = batteries.where((b) => b.batteryModel == currentTab).toList();
        filteredBatteries.sort((a,b) => a.tagName.compareTo(b.tagName));

        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分頁標籤 (Tabs)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: models.map((m) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)),
                        selected: currentTab == m,
                        onSelected: (val) {
                          if (val) setState(() => _selectedBatteryModelTab = m);
                        },
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // 電池小框 (Grid)
                StreamBuilder<List<DronePackage>>(
                  stream: _repository.getPackagesStream(),
                  builder: (context, pkgSnapshot) {
                    final packages = pkgSnapshot.data ?? [];
                    final pkgMap = {for (var p in packages) p.documentId: p.tacticalName};

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 3 : 5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isMobile ? 0.8 : 1.2,
                      ),
                      itemCount: filteredBatteries.length,
                      itemBuilder: (context, index) {
                        final battery = filteredBatteries[index];
                        final isWarning = battery.healthStatus.contains('膨脹');
                        
                        String packageDisplay = '✅ 在庫存';
                        if (battery.currentPackageId != null) {
                          final pName = pkgMap[battery.currentPackageId] ?? battery.currentPackageId;
                          packageDisplay = '📦 $pName';
                        }

                        return Card.outlined(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isWarning ? Colors.red.withOpacity(0.5) : Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AssetDetailScreen(
                                    assetId: battery.documentId,
                                    type: 'battery',
                                    repository: _repository,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    battery.tagName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isWarning ? Colors.red : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: battery.currentPackageId != null 
                                          ? Theme.of(context).colorScheme.secondaryContainer
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      packageDisplay,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: battery.currentPackageId != null 
                                            ? Theme.of(context).colorScheme.onSecondaryContainer
                                            : Colors.green.shade800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('循環:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text('${battery.cycleCount} 次', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('狀態:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Expanded(
                                        child: Text(
                                          battery.healthStatus, 
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ],
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
