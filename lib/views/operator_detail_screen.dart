import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone_operator.dart';
import '../models/drone_package.dart';
import '../models/drone.dart';
import '../models/remote_controller.dart';
import '../models/battery.dart';
import '../repositories/admin_repository.dart';
import '../repositories/fleet_repository.dart';

/// 人員/空拍手 進階詳細履歷與個人看板頁面
class OperatorDetailScreen extends StatefulWidget {
  final String operatorId;
  final AdminRepository adminRepository;
  final FleetRepository fleetRepository;

  const OperatorDetailScreen({
    super.key,
    required this.operatorId,
    required this.adminRepository,
    required this.fleetRepository,
  });

  @override
  State<OperatorDetailScreen> createState() => _OperatorDetailScreenState();
}

class _OperatorDetailScreenState extends State<OperatorDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 取得證照過期剩餘天數
  int? _getExpiryRemainingDays(DateTime? expiryDate) {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference;
  }

  // 更新換證效期日期
  Future<void> _selectExpiryDate(BuildContext context, DroneOperator operator) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: operator.licenseExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: '選擇證照到期日期',
      cancelText: '取消',
      confirmText: '確定',
    );
    if (picked != null) {
      setState(() => _isSaving = true);
      try {
        final updated = operator.copyWith(licenseExpiryDate: picked);
        await widget.adminRepository.updateDroneOperator(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('證照到期日更新成功！'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失敗: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return StreamBuilder<List<DroneOperator>>(
      stream: widget.adminRepository.getDroneOperatorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final operators = snapshot.data ?? [];
        final operator = operators.firstWhere(
          (o) => o.documentId == widget.operatorId,
          orElse: () => DroneOperator(
            documentId: widget.operatorId,
            name: '未知人員',
            phone: '',
            licenseNumber: '',
            createdAt: DateTime.now(),
          ),
        );

        final remainingDays = _getExpiryRemainingDays(operator.licenseExpiryDate);
        final isNearExpiry = remainingDays != null && remainingDays <= 30;

        return Scaffold(
          appBar: AppBar(
            title: Text('${operator.name} 的履歷看板'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(icon: Icon(Icons.badge_outlined), text: '基本資料'),
                Tab(icon: Icon(Icons.handyman_outlined), text: '保管設備'),
                Tab(icon: Icon(Icons.volunteer_activism_outlined), text: '護持紀錄'),
              ],
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // 🚨 換證提醒警示條 (琥珀色發光卡片)
                  if (operator.licenseExpiryDate != null)
                    _buildExpiryAlertBanner(context, operator, remainingDays, isNearExpiry)
                  else
                    _buildNoExpiryBanner(context, operator),

                  // 分頁主體
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(operator),
                        _buildGearTab(operator),
                        _buildActivitiesTab(operator),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isSaving)
                Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  // 1. 證照警示卡片 (Premium Glow Amber)
  Widget _buildExpiryAlertBanner(BuildContext context, DroneOperator operator, int? remainingDays, bool isNearExpiry) {
    final String dateString = '${operator.licenseExpiryDate!.toLocal()}'.split(' ')[0];
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNearExpiry 
            ? Colors.orange.shade50.withOpacity(0.9) 
            : colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearExpiry ? Colors.orangeAccent.shade400 : colorScheme.outlineVariant,
          width: isNearExpiry ? 1.5 : 1,
        ),
        boxShadow: isNearExpiry ? [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Row(
        children: [
          Icon(
            isNearExpiry ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
            color: isNearExpiry ? Colors.orange.shade800 : Colors.green.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNearExpiry ? '🚨 證照即將到期！' : '✅ 證照狀態正常',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isNearExpiry ? Colors.orange.shade900 : colorScheme.onSecondaryContainer,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isNearExpiry 
                      ? '證照效期至 $dateString (剩餘 $remainingDays 天)，請盡速更換！'
                      : '目前效期至 $dateString (剩餘 $remainingDays 天)',
                  style: TextStyle(
                    color: isNearExpiry ? Colors.orange.shade800 : Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _selectExpiryDate(context, operator),
            icon: const Icon(Icons.calendar_month_outlined, size: 16),
            label: const Text('更新到期日'),
            style: TextButton.styleFrom(
              foregroundColor: isNearExpiry ? Colors.orange.shade900 : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoExpiryBanner(BuildContext context, DroneOperator operator) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '尚未設定證照到期日期。設定後系統將自動提供換證倒數提醒！',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _selectExpiryDate(context, operator),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('立即設定'),
          ),
        ],
      ),
    );
  }

  // 2. 基本資料分頁 (含自訂欄位內嵌填寫)
  Widget _buildProfileTab(DroneOperator operator) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card.filled(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          operator.name.isNotEmpty ? operator.name[0] : 'U',
                          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(operator.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('系統加入時間: ${operator.createdAt.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailProfileRow(Icons.phone, '聯絡電話', operator.phone),
                  _buildDetailProfileRow(Icons.card_membership, '合格證照號碼', operator.licenseNumber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text('⚙️ 其他擴充資料 (直接填寫自動儲存)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          
          // 動態顯示自訂擴充屬性 (可直接填寫並背景自動儲存)
          Card.outlined(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('system_dictionaries')
                  .where('category', isEqualTo: 'operator_custom_field')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, dictSnapshot) {
                final globalKeys = dictSnapshot.data?.docs.map((doc) => doc['label'] as String).toList() ?? [];
                final Map<String, String> merged = {};
                for (final k in globalKeys) {
                  merged[k] = operator.customFields[k] ?? '';
                }
                operator.customFields.forEach((key, val) {
                  if (!merged.containsKey(key)) merged[key] = val;
                });

                if (merged.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('無任何自訂欄位屬性。', style: TextStyle(color: Colors.grey))),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: merged.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = merged.keys.elementAt(index);
                    final value = merged[key]!;
                    final isGlobal = globalKeys.contains(key);

                    return CustomFieldRow(
                      label: key,
                      value: value,
                      isGlobal: isGlobal,
                      onSave: (newVal) async {
                        final updatedFields = Map<String, String>.from(operator.customFields)..[key] = newVal;
                        await widget.adminRepository.updateDroneOperator(operator.copyWith(customFields: updatedFields));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 3. 保管設備分頁 (動態聯動 Package & Assets)
  Widget _buildGearTab(DroneOperator operator) {
    return StreamBuilder<List<DronePackage>>(
      stream: widget.fleetRepository.getPackagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allPackages = snapshot.data ?? [];
        // 過濾出保管人為此 Operator 姓名的套裝
        final myPackages = allPackages.where((p) => p.currentKeeper == operator.name).toList();

        if (myPackages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('該人員目前無保管任何便攜盒/設備', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myPackages.length,
          itemBuilder: (context, index) {
            final pkg = myPackages[index];
            return Card.outlined(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                          '📦 ${pkg.tacticalName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pkg.modelType,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // 串接內部飛機與遙控器
                    _buildGearAssetRow(
                      Icons.flight_takeoff,
                      '目前配置空拍機 SN',
                      pkg.currentDroneSn ?? '未配對飛機',
                      pkg.currentDroneSn != null,
                    ),
                    _buildGearAssetRow(
                      Icons.settings_remote,
                      '目前配置遙控器 SN',
                      pkg.currentRcSn ?? '未配對遙控器',
                      pkg.currentRcSn != null,
                    ),

                    // 串接內部電池
                    StreamBuilder<List<Battery>>(
                      stream: widget.fleetRepository.getPackageBatteriesStream(pkg.documentId),
                      builder: (context, batSnap) {
                        final bats = batSnap.data ?? [];
                        if (bats.isEmpty) {
                          return _buildGearAssetRow(Icons.battery_alert, '配置智能電池', '無配置電池', false);
                        }
                        final batTags = bats.map((b) => '${b.tagName} (${b.serialNumber})').join(', ');
                        return _buildGearAssetRow(Icons.battery_charging_full, '配置智能電池', batTags, true);
                      },
                    ),

                    // 配件
                    if (pkg.accessories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('🛠️ 隨附配件清單:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: pkg.accessories.entries.map((e) {
                          return Chip(
                            label: Text('${e.key} x${e.value}'),
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGearAssetRow(IconData icon, String label, String value, bool isLinked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isLinked ? Colors.blue.shade700 : Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isLinked ? FontWeight.bold : FontStyle.italic == FontStyle.italic ? FontWeight.normal : FontWeight.bold,
                fontSize: 13,
                color: isLinked ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. 護持紀錄與回饋分頁 (Timeline + 心得回饋 + 影音模擬卡)
  Widget _buildActivitiesTab(DroneOperator operator) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('operator_activities')
          .where('operatorId', isEqualTo: operator.documentId)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_activity_fab',
            icon: const Icon(Icons.add_task),
            label: const Text('新增護持活動回報'),
            onPressed: () => _showAddActivityDialog(operator),
          ),
          body: () {
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('尚無護持活動紀錄，點擊右下角新增第一筆！', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final activityName = data['activityName'] as String? ?? '未命名活動';
                final date = (data['date'] as Timestamp).toDate();
                final feedback = data['feedback'] as String? ?? '尚無心得感想';
                final mediaUrls = List<String>.from(data['mediaUrls'] ?? []);

                return Card.filled(
                  color: Colors.grey.shade50,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.volunteer_activism, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activityName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                            ),
                            Text(
                              '${date.toLocal()}'.split(' ')[0],
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text(
                          '💬 心得回饋與觀察紀錄：',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          feedback,
                          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                        
                        // 多媒體上傳模擬展示區 (Media Gallery Carousel)
                        if (mediaUrls.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            '📸 任務照片與影音附檔：',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: mediaUrls.length,
                              itemBuilder: (context, picIdx) {
                                return Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(mediaUrls[picIdx]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black12,
                                    ),
                                    child: const Icon(Icons.zoom_in, color: Colors.white70),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }

  // 新增護持活動回報 Dialog (含影音模擬)
  void _showAddActivityDialog(DroneOperator operator) {
    final actNameController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();

    // 模擬已上傳的圖片連結清單
    final List<String> mockUploadedUrls = [
      'https://picsum.photos/id/1018/400/300',
      'https://picsum.photos/id/1043/400/300'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('新增護持活動紀錄'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: actNameController,
                        decoration: const InputDecoration(
                          labelText: '活動/任務名稱',
                          hintText: '如 2026年護法法會空拍安全組',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? '欄位不能為空' : null,
                      ),
                      const SizedBox(height: 16),
                      // 日期選擇器
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        title: const Text('活動日期'),
                        subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
                        trailing: const Icon(Icons.calendar_month_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: feedbackController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '心得回饋與任務觀察紀錄',
                          hintText: '請輸入此趟護持任務的反思、回饋或現場空拍突發狀況紀錄...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? '欄位不能為空' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('📸 模擬媒體附件上傳', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已成功從手機相簿上傳兩張照片至任務附件！'), backgroundColor: Colors.green),
                              );
                            },
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('選擇照片/影片'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 模擬照片預覽網格
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mockUploadedUrls.length,
                          itemBuilder: (context, idx) {
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: DecorationImage(
                                  image: NetworkImage(mockUploadedUrls[idx]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    setState(() => _isSaving = true);
                    try {
                      await FirebaseFirestore.instance.collection('operator_activities').add({
                        'operatorId': widget.operatorId,
                        'activityName': actNameController.text.trim(),
                        'date': Timestamp.fromDate(selectedDate),
                        'feedback': feedbackController.text.trim(),
                        'mediaUrls': mockUploadedUrls,
                      });
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('護持活動紀錄已成功同步上傳！'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('上傳失敗: $e'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  },
                  child: const Text('同步儲存'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// 可重複使用之自訂欄位內嵌行 (與物資詳情保持高度一致)
class CustomFieldRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isGlobal;
  final Future<void> Function(String value) onSave;

  const CustomFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.isGlobal,
    required this.onSave,
  });

  @override
  State<CustomFieldRow> createState() => _CustomFieldRowState();
}

class _CustomFieldRowState extends State<CustomFieldRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSavingLocal = false;
  bool _showSavedCheck = false;
  late String _lastSavedValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _lastSavedValue = widget.value;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _triggerSave();
      }
    });
  }

  @override
  void didUpdateWidget(CustomFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (!_focusNode.hasFocus && _controller.text != widget.value) {
        _controller.text = widget.value;
      }
      _lastSavedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _triggerSave() async {
    final newValue = _controller.text.trim();
    if (newValue == _lastSavedValue.trim()) return;

    setState(() {
      _isSavingLocal = true;
      _showSavedCheck = false;
    });

    try {
      await widget.onSave(newValue);
      _lastSavedValue = newValue;
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
          _showSavedCheck = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showSavedCheck = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 450;
          
          final labelWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (widget.isGlobal) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '全域',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          );

          final inputWidget = TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onFieldSubmitted: (_) => _triggerSave(),
            decoration: InputDecoration(
              hintText: '請輸入${widget.label}',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              suffixIcon: _isSavingLocal
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _showSavedCheck
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 18),
            ),
          );

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: 6),
                inputWidget,
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: labelWidget,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: inputWidget,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
